import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/character.dart';
import '../bloc/characters_bloc.dart';
import '../widgets/character_list_tile.dart';
import '../widgets/search_field.dart';
import '../widgets/state_views.dart';
import 'character_details_screen.dart';

class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<CharactersBloc>()..add(const CharactersStarted()),
    child: const CharactersView(),
  );
}

class CharactersView extends StatelessWidget {
  const CharactersView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CharactersBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Rick and Morty')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchField(
              onChanged: (query) => bloc.add(CharactersQueryChanged(query)),
            ),
          ),
          Expanded(
            child: BlocBuilder<CharactersBloc, CharactersState>(
              builder: (context, state) => switch (state.status) {
                CharactersStatus.initial ||
                CharactersStatus.loading => const LoadingView(),
                CharactersStatus.failure => ErrorView(
                  message: state.failure?.message ?? '',
                  onRetry: () => bloc.add(const CharactersRetryRequested()),
                ),
                CharactersStatus.success when state.characters.isEmpty =>
                  EmptyView(query: state.query),
                CharactersStatus.success => _CharactersList(
                  // Новый ключ для каждого запроса: прокрутка начинается сверху.
                  key: ValueKey(state.query),
                  state: state,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CharactersList extends StatefulWidget {
  const _CharactersList({super.key, required this.state});

  final CharactersState state;

  @override
  State<_CharactersList> createState() => _CharactersListState();
}

class _CharactersListState extends State<_CharactersList> {
  static const _loadMoreThreshold = 400.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final state = widget.state;
    // После ошибки подгрузки ждём нажатия «Повторить», а не долбим API при прокрутке.
    if (position.extentAfter < _loadMoreThreshold &&
        !state.hasReachedMax &&
        state.loadMoreFailure == null) {
      context.read<CharactersBloc>().add(const CharactersNextPageRequested());
    }
  }

  void _openDetails(Character character) {
    // Список остаётся в стеке навигации, поэтому при возврате
    // сохраняются и прокрутка, и загруженные страницы, и поиск.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterDetailsScreen(character: character),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final characters = state.characters;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: characters.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= characters.length) {
          return _ListFooter(
            failureMessage: state.loadMoreFailure?.message,
            onRetry: () => context.read<CharactersBloc>().add(
              const CharactersNextPageRequested(),
            ),
          );
        }
        final character = characters[index];
        return CharacterListTile(
          character: character,
          onTap: () => _openDetails(character),
        );
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.failureMessage, required this.onRetry});

  final String? failureMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (failureMessage == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(failureMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
