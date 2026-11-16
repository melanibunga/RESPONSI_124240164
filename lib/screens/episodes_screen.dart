// import 'package:flutter/material.dart';

// import '../models/episode.dart';
// import '../services/api_service.dart';
// import '../theme.dart';
// import 'widgets.dart';

// class EpisodesScreen extends StatefulWidget {
//   const EpisodesScreen({super.key});

//   @override
//   State<EpisodesScreen> createState() => _EpisodesScreenState();
// }

// class _EpisodesScreenState extends State<EpisodesScreen> {
//   late Future<List<Episode>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = ApiService.fetchEpisodes();
//   }

//   void _reload() => setState(() => _future = ApiService.fetchEpisodes());

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Episode>>(
//       future: _future,
//       builder: (context, snap) {
//         if (snap.connectionState != ConnectionState.done) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snap.hasError) {
//           return ErrorView(message: snap.error.toString(), onRetry: _reload);
//         }
//         final episodes = snap.data!;
//         return ListView.builder(
//           padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
//           itemCount: episodes.length,
//           itemBuilder: (context, i) {
//             final e = episodes[i];
//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 4),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: AppColors.lime,
//                   foregroundColor: AppColors.oliveDark,
//                   child: Text('${e.id}',
//                       style: const TextStyle(fontWeight: FontWeight.w600)),
//                 ),
//                 title: Text(e.name,
//                     style: const TextStyle(fontWeight: FontWeight.w600)),
//                 subtitle: Text('${e.code}  •  ${e.airDate}',
//                     style: const TextStyle(color: AppColors.muted)),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
