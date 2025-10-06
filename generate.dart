// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart generate.dart <command>:<name>');
    print('Available commands: page, provider, model, widget, repository');
    exit(1);
  }

  // Handle screen command with special format
  if (arguments[0] == 'screen' &&
      arguments.length >= 4 &&
      arguments[2] == 'on') {
    final screenName = arguments[1];
    final pageName = arguments[3];
    generateScreenOnPage(screenName, pageName);
    return;
  }

  // Handle repository command with special format
  if (arguments[0].startsWith('repository:') &&
      arguments.length >= 3 &&
      arguments[1] == 'on') {
    final repoParts = arguments[0].split(':');
    if (repoParts.length != 2) {
      print(
        'Invalid repository format. Use: repository:<repo_name> on <page_name>',
      );
      exit(1);
    }

    final repoName = repoParts[1];
    final pageName = arguments[2];
    generateRepositoryOnPage(repoName, pageName);
    return;
  }

  final command = arguments[0];
  final parts = command.split(':');

  if (parts.length != 2) {
    print('Invalid command format. Use: <command>:<name>');
    exit(1);
  }

  final type = parts[0];
  final name = parts[1];

  switch (type) {
    case 'page':
      generatePage(name);
      break;
    case 'provider':
      generateProvider(name);
      break;
    case 'model':
      generateModel(name);
      break;
    case 'widget':
      generateWidget(name);
      break;
    case 'repository':
      print('For repository, use: repository:<repo_name> on <page_name>');
      break;
    default:
      print('Unknown command: $type');
      print('Available commands: page, provider, model, widget');
      exit(1);
  }
}

String toCamelCase(String input) {
  if (input.contains('.')) {
    final parts = input.split('.');
    return parts
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join();
  }
  return input[0].toUpperCase() + input.substring(1);
}

String toSnakeCase(String input) {
  if (input.contains('.')) {
    return input.replaceAll('.', '_');
  }
  return input;
}

extension on File {
  void printCreated() => print('Generated: $path');
}

void generatePage(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  // Generate page widget with Riverpod
  final pageContent =
      '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/${fileName}_provider.dart';

class ${className}Page extends ConsumerWidget {
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(${fileName}NotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$className'),
        centerTitle: true,
      ),
      body: asyncState.when(
        data: (data) => const Center(
          child: Text(
            '${className}Page is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: \$error')),
      ),
    );
  }
}
''';

  // Generate provider with AsyncNotifier
  final providerContent =
      '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${fileName}_provider.g.dart';

@riverpod
class ${className}Notifier extends _\$${className}Notifier {
  @override
  Future<void> build() async {
    // Initialize your async state here
    return;
  }
  
  // Add your business logic methods here
  Future<void> loadData() async {
    state = const AsyncLoading();
    try {
      // Your async operation here
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

''';

  // Generate state model
  final stateContent =
      '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${fileName}_model.freezed.dart';
part '${fileName}_model.g.dart';

@freezed
class ${className}Model with _\$${className}Model {
  const factory ${className}Model({
    required String id,
    required String name,
    // Add your fields here
  }) = _${className}Model;

  factory ${className}Model.fromJson(Map<String, dynamic> json) =>
      _\$${className}ModelFromJson(json);
}
''';

  // Create directories
  final basePath = 'lib/features/$fileName';
  final pagesDir = Directory('$basePath/presentation/pages');
  final providersDir = Directory('$basePath/presentation/providers');
  final modelsDir = Directory('$basePath/domain/models');
  final repositoriesDir = Directory('$basePath/data/repositories');
  final datasourcesDir = Directory('$basePath/data/datasources');

  final directories = [
    pagesDir,
    providersDir,
    modelsDir,
    repositoriesDir,
    datasourcesDir,
  ];

  for (final dir in directories) {
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('Created directory: ${dir.path}');
    }
  }

  // Write files
  final pageFile = File('${pagesDir.path}/${fileName}_page.dart');
  final providerFile = File('${providersDir.path}/${fileName}_provider.dart');
  final stateFile = File('${modelsDir.path}/${fileName}_model.dart');

  pageFile.writeAsStringSync(pageContent);
  providerFile.writeAsStringSync(providerContent);
  stateFile.writeAsStringSync(stateContent);

  print('Generated page: ${pageFile.path}');
  print('Generated provider: ${providerFile.path}');
  print('Generated state: ${stateFile.path}');

  // Generate additional layers
  generateRepositoryOnPage(name, name);
  generateDatasource(name, name);

  // Update app router
  updateAppRouter(className, fileName);
}

void generateProvider(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  final content =
      '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${fileName}_provider.g.dart';

@riverpod
class ${className}Notifier extends _\$${className}Notifier {
  @override
  Future<void> build() async {
    // Initialize your provider here
    return;
  }
  
  // Add your state management logic here
  Future<void> performAction() async {
    state = const AsyncLoading();
    try {
      // Your business logic here
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

''';

  final dir = Directory('lib/providers/$fileName');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('${dir.path}/${fileName}_provider.dart');
  file.writeAsStringSync(content);
  print('Generated provider: ${file.path}');
}

void generateModel(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  final content =
      '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${fileName}_model.freezed.dart';
part '${fileName}_model.g.dart';

@freezed
class ${className}Model with _\$${className}Model {
  const factory ${className}Model({
    required String id,
    required String name,
    // Add your fields here
  }) = _${className}Model;

  factory ${className}Model.fromJson(Map<String, dynamic> json) =>
      _\$${className}ModelFromJson(json);
}
''';

  final dir = Directory('lib/models/$fileName');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('${dir.path}/${fileName}_model.dart');
  file.writeAsStringSync(content);
  print('Generated model: ${file.path}');
}

void generateScreenOnPage(String screenName, String pageName) {
  final screenClassName = toCamelCase(screenName);
  final screenFileName = toSnakeCase(screenName);
  final pageFileName = toSnakeCase(pageName);

  // Check if page exists
  final pageDir = Directory('lib/features/$pageFileName');
  if (!pageDir.existsSync()) {
    print('❌ ERROR: Page "$pageName" does not exist!');
    print(
      'Please create the page first using: dart generate.dart page:$pageName',
    );
    print('Available pages:');

    // List available pages
    final featuresDir = Directory('lib/features');
    if (featuresDir.existsSync()) {
      final directories = featuresDir.listSync();
      for (final dir in directories) {
        if (dir is Directory) {
          print('  - ${dir.path.split('/').last}');
        }
      }
    }

    exit(1);
  }

  // Create screen directory if not exists
  final screenDir = Directory(
    'lib/features/$pageFileName/presentation/pages/screens',
  );
  if (!screenDir.existsSync()) {
    screenDir.createSync(recursive: true);
    print('Created directory: ${screenDir.path}');
  }

  // Generate screen content
  final screenContent =
      '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/${pageFileName}_provider.dart';

class ${screenClassName}Screen extends ConsumerWidget {
  const ${screenClassName}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // You can watch specific providers here
    // final state = ref.watch(someProvider);
    
    return const Center(
      child: Text('${screenClassName}Screen is working'),
    );
  }
}
''';

  // Write screen file
  final screenFile = File('${screenDir.path}/${screenFileName}_screen.dart');
  screenFile.writeAsStringSync(screenContent);

  print('✅ Generated screen: ${screenFile.path}');
  print('📁 Location: lib/features/$pageFileName/presentation/pages/screens/');
  print(
    '🎉 Screen "$screenClassName" successfully created on page "$pageName"',
  );
}

void generateWidget(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  final content =
      '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ${className}Widget extends ConsumerWidget {
  const ${className}Widget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('$className Widget'),
    );
  }
}
''';

  final dir = Directory('lib/widgets');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('${dir.path}/${fileName}_widget.dart');
  file.writeAsStringSync(content);
  print('Generated widget: ${file.path}');
}

void updateAppRouter(String className, String fileName) {
  // Create navigation directory if not exists
  final navDir = Directory('lib/core/navigation');
  if (!navDir.existsSync()) {
    navDir.createSync(recursive: true);
  }

  // Update route_paths.dart
  final routePathsFile = File('${navDir.path}/route_paths.dart');
  if (!routePathsFile.existsSync()) {
    routePathsFile.writeAsStringSync('''
abstract class RoutePaths {
  static const String ${fileName.toUpperCase()} = '/$fileName';
}
''');
  } else {
    var content = routePathsFile.readAsStringSync();
    if (!content.contains('static const String ${fileName.toUpperCase()}')) {
      final lastBraceIndex = content.lastIndexOf('}');
      if (lastBraceIndex != -1) {
        final newRoute =
            '  static const String ${fileName.toUpperCase()} = \'/$fileName\';\n';
        content = content.replaceRange(
          lastBraceIndex - 1,
          lastBraceIndex - 1,
          newRoute,
        );
        routePathsFile.writeAsStringSync(content);
      }
    }
  }

  // Update app_router.dart
  final appRouterFile = File('${navDir.path}/app_router.dart');
  if (!appRouterFile.existsSync()) {
    appRouterFile.writeAsStringSync('''
import 'package:go_router/go_router.dart';
import 'route_paths.dart';
import '../../features/$fileName/presentation/pages/${fileName}_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: RoutePaths.${fileName.toUpperCase()},
      builder: (context, state) => const ${className}Page(),
    ),
  ],
);
''');
  } else {
    var content = appRouterFile.readAsStringSync();
    if (!content.contains('${className}Page')) {
      // Add import
      if (!content.contains(
        'import \'../../features/$fileName/presentation/pages/${fileName}_page.dart\';',
      )) {
        final importIndex = content.indexOf('import \'route_paths.dart\';');
        if (importIndex != -1) {
          content = content.replaceRange(
            importIndex + 'import \'route_paths.dart\';'.length,
            importIndex + 'import \'route_paths.dart\';'.length,
            '\nimport \'../../features/$fileName/presentation/pages/${fileName}_page.dart\';',
          );
        }
      }

      // Add route
      final routesIndex = content.indexOf('routes: [');
      if (routesIndex != -1) {
        final routesEndIndex = content.indexOf('],', routesIndex);
        if (routesEndIndex != -1) {
          final routeEntry =
              '''
    GoRoute(
      path: RoutePaths.${fileName.toUpperCase()},
      builder: (context, state) => const ${className}Page(),
    ),''';
          content = content.replaceRange(
            routesEndIndex,
            routesEndIndex,
            routeEntry,
          );
        }
      }

      appRouterFile.writeAsStringSync(content);
    }
  }

  print('Updated app router for $className');
}

void generateRepositoryOnPage(String repoName, String pageName) {
  final repoClassName = toCamelCase(repoName);
  final repoFileName = toSnakeCase(repoName);
  final pageFileName = toSnakeCase(pageName);

  // Check if page exists
  final pageDir = Directory('lib/features/$pageFileName');
  if (!pageDir.existsSync()) {
    print('❌ ERROR: Page "$pageName" does not exist!');
    print(
      'Please create the page first using: dart generate.dart page:$pageName',
    );
    print('Available pages:');

    // List available pages
    final featuresDir = Directory('lib/features');
    if (featuresDir.existsSync()) {
      final directories = featuresDir.listSync();
      for (final dir in directories) {
        if (dir is Directory) {
          print('  - ${dir.path.split('/').last}');
        }
      }
    }

    exit(1);
  }

  // Create repositories directory if not exists
  final repoDir = Directory('lib/features/$pageFileName/data/repositories');
  if (!repoDir.existsSync()) {
    repoDir.createSync(recursive: true);
    print('Created directory: ${repoDir.path}');
  }

  // Generate abstract repository for domain
  final abstractRepoContent =
      '''
abstract class ${repoClassName}Repository {
  // Define your repository contract here
  Future<void> performOperation();
}
''';

  // Generate implementation repository for data
  final implRepoContent =
      '''
import '../../domain/repositories/${repoFileName}_repository.dart';
import '../datasources/${repoFileName}_datasource.dart';

class ${repoClassName}RepositoryImpl implements ${repoClassName}Repository {
  final ${repoClassName}Datasource _datasource;

  ${repoClassName}RepositoryImpl(this._datasource);

  @override
  Future<void> performOperation() async {
    return await _datasource.performOperation();
  }
}
''';

  // Create domain repositories directory if not exists
  final domainRepoDir = Directory(
    'lib/features/$pageFileName/domain/repositories',
  );
  if (!domainRepoDir.existsSync()) {
    domainRepoDir.createSync(recursive: true);
    print('Created directory: ${domainRepoDir.path}');
  }

  // Write abstract repository file (domain)
  final abstractRepoFile = File(
    '${domainRepoDir.path}/${repoFileName}_repository.dart',
  );
  abstractRepoFile.writeAsStringSync(abstractRepoContent);

  // Write implementation repository file (data)
  final implRepoFile = File(
    '${repoDir.path}/${repoFileName}_repository_impl.dart',
  );
  implRepoFile.writeAsStringSync(implRepoContent);

  print('✅ Generated abstract repository: ${abstractRepoFile.path}');
  print('✅ Generated implementation repository: ${implRepoFile.path}');
  print('📁 Location: lib/features/$pageFileName/');
  print(
    '🎉 Repository "$repoClassName" successfully created on page "$pageName"',
  );
  print('');
  print('💡 Next steps:');
  print('   1. Implement the actual data source logic in the repository impl');
  print('   2. Add dependency injection in your provider:');
  print(
    '      final repository = ref.watch(${repoFileName}RepositoryProvider);',
  );
}

void generateEntities(String name, String pageName) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);
  final pageFileName = toSnakeCase(pageName);

  final content =
      '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${fileName}_entity.freezed.dart';

@freezed
class ${className}Entity with _\$${className}Entity {
  const factory ${className}Entity({
    required String id,
    // Add your entity fields here
  }) = _${className}Entity;
}
''';

  final dir = Directory('lib/features/$pageFileName/domain/entities');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  File('${dir.path}/${fileName}_entity.dart')
    ..writeAsStringSync(content)
    ..printCreated();
}

/// Entry-point:  dart generate.dart datasource:<name> on <page>
void generateDatasource(String name, String pageName) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);
  final pageFileName = toSnakeCase(pageName);

  /* ---------- 1.  Verify that the repository abstract exists ---------- */
  final repositoryAbstractFile = File(
    'lib/features/$pageFileName/domain/repositories/${fileName}_repository.dart',
  );
  if (!repositoryAbstractFile.existsSync()) {
    print('❌ ERROR: Repository abstract not found!');
    print('Create it first:  dart generate.dart repository:$name on $pageName');
    exit(1);
  }

  /* ---------- 2.  Read the abstract and steal its signatures ---------- */
  final repoContent = repositoryAbstractFile.readAsStringSync();
  final methods = RegExp(
    r'Future<.*?>?\s+\w+\([^)]*\);',
  ).allMatches(repoContent).map((m) => m.group(0)!).toList();

  if (methods.isEmpty) {
    print(
      '⚠️  WARNING: No methods found in repository – empty datasources generated.',
    );
  }

  /* ---------- 3.  Build identical implementations for LOCAL ---------- */
  final localContent =
      '''
import '../../domain/repositories/${fileName}_repository.dart';

class ${className}LocalDatasource implements ${className}Repository {
${methods.map((m) => '  @override\n  $m').join('\n\n  ')}
}
''';

  /* ---------- 4.  Build identical implementations for NETWORK ---------- */
  final networkContent =
      '''
import '../../domain/repositories/${fileName}_repository.dart';

class ${className}NetworkDatasource implements ${className}Repository {
${methods.map((m) => '  @override\n  $m').join('\n\n  ')}
}
''';

  /* ---------- 5.  Persist the two files ---------- */
  final dir = Directory('lib/features/$pageFileName/data/datasources')
    ..createSync(recursive: true);

  File('${dir.path}/${fileName}_local_datasource.dart')
    ..writeAsStringSync(localContent)
    ..printCreated();

  File('${dir.path}/${fileName}_network_datasource.dart')
    ..writeAsStringSync(networkContent)
    ..printCreated();

  /* ---------- 6.  (Optional) keep repository-impl in sync ---------- */
  _syncRepositoryImpl(name, pageName, methods);
}

/* --------------------------------------------------------------- */
/* Keeps the existing *Impl class in sync with the two datasources */
/* --------------------------------------------------------------- */
void _syncRepositoryImpl(
  String repoName,
  String pageName,
  List<String> methods,
) {
  final className = toCamelCase(repoName);
  final fileName = toSnakeCase(repoName);
  final pageFileName = toSnakeCase(pageName);

  final implFile = File(
    'lib/features/$pageFileName/data/repositories/${fileName}_repository_impl.dart',
  );
  if (!implFile.existsSync()) return; // nothing to do

  var content = implFile.readAsStringSync();

  /* 1.  Update constructor --------------------------------------------------*/
  final oldCtorField = RegExp(
    'final\\s+${className}Datasource\\s+_datasource;',
  );
  final newCtorFields =
      '''
  final ${className}LocalDatasource _local;
  final ${className}NetworkDatasource _network;''';

  content = content.replaceFirst(oldCtorField, newCtorFields);
  content = content.replaceFirst(
    '${className}RepositoryImpl(this._datasource);',
    '${className}RepositoryImpl(this._local, this._network);',
  );

  /* 2.  Update every method to “network-first / local-fallback” -------------*/
  for (final method in methods) {
    final methodName = RegExp(r'\s+(\w+)\(').firstMatch(method)!.group(1)!;
    final newImpl =
        '''
  @override
  $method async {
    try {
      return await _network.$methodName();
    } catch (_) {
      return await _local.$methodName();
    }
  }''';

    final existingMethod = RegExp(
      r'@override\s+Future<.*?>?\s+' +
          methodName +
          r'\(\)\s*async\s*\{[^{}]*\}',
    );
    content = content.replaceFirst(existingMethod, newImpl);
  }

  implFile.writeAsStringSync(content);
  print('♻️  Repository implementation updated to use both datasources.');
}
