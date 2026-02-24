import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/constants/reciters.dart';
import 'package:ramadan_project/features/audio/domain/entities/reciter.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';

class ReciterSelectionSheet extends StatelessWidget {
  const ReciterSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'اختر القارئ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'UthmanTaha',
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: Reciters.all.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final reciter = Reciters.all[index];
                return _ReciterItem(reciter: reciter);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReciterItem extends StatelessWidget {
  final Reciter reciter;

  const _ReciterItem({required this.reciter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      buildWhen: (previous, current) =>
          previous.selectedReciter != current.selectedReciter,
      builder: (context, state) {
        final isSelected = state.selectedReciter.id == reciter.id;
        return ListTile(
          onTap: () {
            context.read<AudioBloc>().add(AudioReciterChanged(reciter));
            Navigator.pop(context);
          },
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? Colors.green.shade100
                : Colors.grey.shade200,
            child: Icon(
              Icons.person,
              color: isSelected ? Colors.green : Colors.grey,
            ),
          ),
          title: Text(
            reciter.arabicName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
        );
      },
    );
  }
}
