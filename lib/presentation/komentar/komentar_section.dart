import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/komentar_model.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/komentar_bloc.dart';

import '../auth/bloc/auth_state.dart';

class KomentarSection extends StatefulWidget {
  final int laporanId;
  final bool showInput;

  const KomentarSection({
    super.key,
    required this.laporanId,
    this.showInput = true,
  });

  @override
  State<KomentarSection> createState() => _KomentarSectionState();
}

class _KomentarSectionState extends State<KomentarSection> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KomentarBloc, KomentarState>(
      listener: (context, state) {
        if (state is KomentarLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildKomentarList(state),
            if (widget.showInput) _buildInputField(context),
          ],
        );
      },
    );
  }

  Widget _buildKomentarList(KomentarState state) {
    if (state is KomentarLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is KomentarError) {
      return Text(state.message);
    } else if (state is KomentarLoaded) {
      if (state.response.data.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Belum ada komentar'),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.response.data.length,
        itemBuilder: (context, index) {
          final komentar = state.response.data[index];
          return _buildKomentarItem(komentar);
        },
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildKomentarItem(Komentar komentar) {
    final authState = context.read<AuthBloc>().state;
    final isCurrentUser =
        authState is AuthAuthenticated &&
        authState.user.id == komentar.idPengguna;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  komentar.namaPengguna,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  komentar.waktuLalu,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(komentar.isiKomentar),
            if (isCurrentUser)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () {
                    context.read<KomentarBloc>().add(
                      DeleteKomentar(
                        id: komentar.id,
                        idPengguna: komentar.idPengguna,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Tulis komentar...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty &&
                      authState is AuthAuthenticated) {
                    context.read<KomentarBloc>().add(
                      AddKomentar(
                        idPengguna: authState.user.id,
                        idLaporan: widget.laporanId,
                        isiKomentar: _controller.text.trim(),
                      ),
                    );
                    _controller.clear();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
