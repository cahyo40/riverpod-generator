// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart generate.dart <command>:<name>');
    print('Available commands: page, provider, model, widget, repository');
    exit(1);
  }

  if (arguments[0] == 'init') {
    initProject();
    generatePage("home");
    return;
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
    case 'crud':
      generateCrudTemplate(name);
      break;
    default:
      print('Unknown command: $type');
      print('Available commands: page, provider, model, widget');
      exit(1);
  }
}

String toKebabCase(String input) {
  if (input.contains('.')) {
    final parts = input.split('.');
    return parts[0] + parts.skip(1).map((e) => capitalize(e)).join();
  }
  return input;
}

/// Kapitalisasi huruf pertama: home -> Home
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
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
  final notifierName = toKebabCase(name);

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
    final asyncState = ref.watch(${notifierName}NotifierProvider);
    
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
abstract class ${className}Model with _\$${className}Model {
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
  final className = toCamelCase(repoName);
  final fileName = toSnakeCase(repoName);
  final pageFileName = toSnakeCase(pageName);

  /* ---- 1. pastikan page-nya sudah ada ---- */
  final pageDir = Directory('lib/features/$pageFileName');
  if (!pageDir.existsSync()) {
    print('❌ ERROR: Page "$pageName" does not exist!');
    print('Create it first:  dart generate.dart page:$pageName');
    exit(1);
  }

  /* ---- 2. buat folder domain/repositories & data/repositories ---- */
  final domainRepoDir = Directory(
    'lib/features/$pageFileName/domain/repositories',
  )..createSync(recursive: true);
  final dataRepoDir = Directory('lib/features/$pageFileName/data/repositories')
    ..createSync(recursive: true);

  /* ---- 3. abstract repository (KOSONG) ---- */
  final abstractContent =
      '''
abstract class ${className}Repository {
  // define your contract here
}
''';
  File('${domainRepoDir.path}/${fileName}_repository.dart')
    ..writeAsStringSync(abstractContent)
    ..printCreated();

  /* ---- 4. repository impl (sudah import 2 datasource) ---- */
  final implContent =
      '''
import '../../domain/repositories/${fileName}_repository.dart';
import '../datasources/${fileName}_local_datasource.dart';
import '../datasources/${fileName}_network_datasource.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  final ${className}LocalDatasource _local;
  final ${className}NetworkDatasource _network;

  ${className}RepositoryImpl(this._local, this._network);

  // implement your methods here (network-first, local-fallback)
}
''';
  File('${dataRepoDir.path}/${fileName}_repository_impl.dart')
    ..writeAsStringSync(implContent)
    ..printCreated();

  print('✅ Repository "$repoName" created on page "$pageName"');
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
  if (!implFile.existsSync()) return;

  var content = implFile.readAsStringSync();

  /* 1. pastikan import-nya 2 file datasource */
  final importLocal =
      "import '../datasources/${fileName}_local_datasource.dart';";
  final importNetwork =
      "import '../datasources/${fileName}_network_datasource.dart';";

  if (!content.contains(importLocal)) {
    // tambahkan tepat setelah baris import abstract
    content = content.replaceFirst(
      "import '../../domain/repositories/${fileName}_repository.dart';",
      "import '../../domain/repositories/${fileName}_repository.dart';\n$importLocal",
    );
  }
  if (!content.contains(importNetwork)) {
    content = content.replaceFirst(
      "import '../../domain/repositories/${fileName}_repository.dart';",
      "import '../../domain/repositories/${fileName}_repository.dart';\n$importNetwork",
    );
  }

  /* 2. update constructor kalau masih lama */
  final oldField = RegExp('final\\s+${className}Datasource\\s+_\\w+;');
  final newFields =
      '''
  final ${className}LocalDatasource _local;
  final ${className}NetworkDatasource _network;''';
  content = content.replaceFirst(oldField, newFields);

  content = content.replaceFirst(
    RegExp('${className}RepositoryImpl\\(this\\._\\w+\\);'),
    '${className}RepositoryImpl(this._local, this._network);',
  );

  /* 3. isi setiap method dengan network-first / local-fallback */
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
  print('♻️  RepositoryImpl updated (imports + methods).');
}

void generateCrudTemplate(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  /* ---------- abstract repository ---------- */
  final abstractRepo =
      '''
abstract class ${className}Repository {
  Future<List<${className}Entity>> getAll();
  Future<${className}Entity?> getById(String id);
  Future<void> create(${className}Entity entity);
  Future<void> update(${className}Entity entity);
  Future<void> delete(String id);
}
''';
  final repoDir = Directory('lib/features/$fileName/domain/repositories')
    ..createSync(recursive: true);
  File('${repoDir.path}/${fileName}_repository.dart')
    ..writeAsStringSync(abstractRepo)
    ..printCreated();

  /* ---------- entity (minimal) ---------- */
  final entity =
      '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${fileName}_entity.freezed.dart';

@freezed
class ${className}Entity with _\$${className}Entity {
  const factory ${className}Entity({
    required String id,
    required String name,
  }) = _${className}Entity;
}
''';
  final entityDir = Directory('lib/features/$fileName/domain/entities')
    ..createSync(recursive: true);
  File('${entityDir.path}/${fileName}_entity.dart')
    ..writeAsStringSync(entity)
    ..printCreated();

  /* ---------- repository impl ---------- */
  final impl =
      '''
import '../../domain/repositories/${fileName}_repository.dart';
import '../datasources/${fileName}_local_datasource.dart';
import '../datasources/${fileName}_network_datasource.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  final ${className}LocalDatasource _local;
  final ${className}NetworkDatasource _network;

  ${className}RepositoryImpl(this._local, this._network);

  @override
  Future<List<${className}Entity>> getAll() async =>
      await _network.getAll().catchError((_) => _local.getAll());

  @override
  Future<${className}Entity?> getById(String id) async =>
      await _network.getById(id).catchError((_) => _local.getById(id));

  @override
  Future<void> create(${className}Entity entity) async {
    try {
      await _network.create(entity);
      await _local.create(entity); // simpan cache
    } catch (_) {
      await _local.create(entity);
    }
  }

  @override
  Future<void> update(${className}Entity entity) async {
    try {
      await _network.update(entity);
      await _local.update(entity);
    } catch (_) {
      await _local.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _network.delete(id);
      await _local.delete(id);
    } catch (_) {
      await _local.delete(id);
    }
  }
}
''';
  final implDir = Directory('lib/features/$fileName/data/repositories')
    ..createSync(recursive: true);
  File('${implDir.path}/${fileName}_repository_impl.dart')
    ..writeAsStringSync(impl)
    ..printCreated();

  /* ---------- local datasource ---------- */
  final localDs =
      '''
import '../../domain/repositories/${fileName}_repository.dart';

class ${className}LocalDatasource implements ${className}Repository {
  @override
  Future<List<${className}Entity>> getAll() async => [];

  @override
  Future<${className}Entity?> getById(String id) async => null;

  @override
  Future<void> create(${className}Entity entity) async {}

  @override
  Future<void> update(${className}Entity entity) async {}

  @override
  Future<void> delete(String id) async {}
}
''';
  final dsDir = Directory('lib/features/$fileName/data/datasources')
    ..createSync(recursive: true);
  File('${dsDir.path}/${fileName}_local_datasource.dart')
    ..writeAsStringSync(localDs)
    ..printCreated();

  /* ---------- network datasource ---------- */
  final networkDs =
      '''
import '../../domain/repositories/${fileName}_repository.dart';

class ${className}NetworkDatasource implements ${className}Repository {
  @override
  Future<List<${className}Entity>> getAll() async => [];

  @override
  Future<${className}Entity?> getById(String id) async => null;

  @override
  Future<void> create(${className}Entity entity) async {}

  @override
  Future<void> update(${className}Entity entity) async {}

  @override
  Future<void> delete(String id) async {}
}
''';
  File('${dsDir.path}/${fileName}_network_datasource.dart')
    ..writeAsStringSync(networkDs)
    ..printCreated();

  print('✅ CRUD template for "$name" completed.');
}

// Template untuk tasks.json
const String defaultTasksJson = '''
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate Page",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "page:\${input:pageName}"],
      "problemMatcher": []
    },
    {
      "label": "Generate Provider",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "provider:\${input:providerName}"],
      "problemMatcher": []
    },
    {
      "label": "Generate Screen on Page",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "screen", "\${input:screenName}", "on", "\${input:pageName}"],
      "problemMatcher": []
    },
    {
      "label": "Generate Repository on Page",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "repository:\${input:repoName}", "on", "\${input:pageName}"],
      "problemMatcher": []
    },
    {
      "label": "Generate Model",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "model:\${input:modelName}"],
      "problemMatcher": []
    },
    {
      "label": "Generate Widget",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "widget:\${input:widgetName}"],
      "problemMatcher": []
    },
    {
      "label": "Generate Entity",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "entity:\${input:entityName}"],
      "problemMatcher": []
    },
    {
      "label": "Generate CRUD Template",
      "type": "shell",
      "command": "dart",
      "args": ["generate.dart", "crud:\${input:crudName}"],
      "problemMatcher": []
    }
  ],
  "inputs": [
    {
      "id": "pageName",
      "type": "promptString",
      "description": "Enter page name (e.g., home or settings.profile):"
    },
    {
      "id": "providerName",
      "type": "promptString",
      "description": "Enter provider name (e.g., user, settings):"
    },
    {
      "id": "screenName",
      "type": "promptString",
      "description": "Enter screen name (e.g., login, profile):"
    },
    {
      "id": "repoName",
      "type": "promptString",
      "description": "Enter repository name (e.g., login, user):"
    },
    {
      "id": "modelName",
      "type": "promptString",
      "description": "Enter model name:"
    },
    {
      "id": "widgetName",
      "type": "promptString",
      "description": "Enter widget name:"
    },
    {
      "id": "entityName",
      "type": "promptString",
      "description": "Enter entity name:"
    },
    {
      "id": "crudName",
      "type": "promptString",
      "description": "Enter feature name for CRUD template:"
    }
  ]
}
''';

// Template untuk main.dart
const String defaultMainDart = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'My Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
    );
  }
}

''';

void initProject() async {
  print('🚀 Initializing Flutter Code Generator...\n');
  print('⚠️  This will overwrite main.dart and tasks.json if they exist.\n');

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print(
      '❌ Error: pubspec.yaml not found. Are you in a Flutter project root?',
    );
    exit(1);
  }

  final lines = pubspecFile.readAsLinesSync();

  final depsToAdd = {
    'flutter_riverpod': '^2.5.1',
    'freezed_annotation': '^2.4.4',
    'go_router': '^14.2.3',
    'riverpod_annotation': '^2.3.5',
    'json_annotation': '^4.9.0',
  };

  final devDepsToAdd = {
    'build_runner': '^2.4.11',
    'freezed': '^2.5.7',
    'riverpod_generator': '^2.4.3',
    'json_serializable': '^6.9.0',
  };

  print('🔧 Checking pubspec.yaml...\n');

  final newLines = <String>[];
  bool inFlutterBlock = false;
  bool inFlutterTestBlock = false;
  bool depsSectionFound = false;
  bool devDepsSectionFound = false;
  bool modified = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    newLines.add(line);

    if (trimmed == 'flutter:') {
      inFlutterBlock = true;
      continue;
    }
    if (trimmed == 'flutter_test:') {
      inFlutterTestBlock = true;
      continue;
    }

    if (inFlutterBlock &&
        !line.startsWith('  ') &&
        trimmed.isNotEmpty &&
        !trimmed.startsWith('#')) {
      inFlutterBlock = false;
    }
    if (inFlutterTestBlock &&
        !line.startsWith('  ') &&
        trimmed.isNotEmpty &&
        !trimmed.startsWith('#')) {
      inFlutterTestBlock = false;
    }

    if (inFlutterBlock &&
        depsToAdd.isNotEmpty &&
        (i + 1 >= lines.length || !lines[i + 1].startsWith('  '))) {
      for (final entry in depsToAdd.entries.toList()) {
        if (!lines.any((l) => l.contains('${entry.key}:'))) {
          newLines.add('  ${entry.key}: ${entry.value}');
          print('✅ Added dependency: ${entry.key}: ${entry.value}');
          modified = true;
        }
        depsToAdd.remove(entry.key);
      }
    }

    if (inFlutterTestBlock &&
        devDepsToAdd.isNotEmpty &&
        (i + 1 >= lines.length || !lines[i + 1].startsWith('  '))) {
      for (final entry in devDepsToAdd.entries.toList()) {
        if (!lines.any((l) => l.contains('${entry.key}:'))) {
          newLines.add('  ${entry.key}: ${entry.value}');
          print('✅ Added dev_dependency: ${entry.key}: ${entry.value}');
          modified = true;
        }
        devDepsToAdd.remove(entry.key);
      }
    }

    if (trimmed == 'dependencies:') {
      depsSectionFound = true;
    } else if (trimmed == 'dev_dependencies:') {
      devDepsSectionFound = true;
    }
  }

  if (depsToAdd.isNotEmpty && depsSectionFound) {
    newLines.add('');
    for (final entry in depsToAdd.entries) {
      if (!lines.any((l) => l.contains('${entry.key}:'))) {
        newLines.add('  ${entry.key}: ${entry.value}');
        print('✅ Added dependency: ${entry.key}: ${entry.value}');
        modified = true;
      }
    }
  }

  if (devDepsToAdd.isNotEmpty && devDepsSectionFound) {
    newLines.add('');
    for (final entry in devDepsToAdd.entries) {
      if (!lines.any((l) => l.contains('${entry.key}:'))) {
        newLines.add('  ${entry.key}: ${entry.value}');
        print('✅ Added dev_dependency: ${entry.key}: ${entry.value}');
        modified = true;
      }
    }
  }

  if (!depsSectionFound) {
    newLines.add('');
    newLines.add('dependencies:');
    for (final entry in depsToAdd.entries) {
      newLines.add('  ${entry.key}: ${entry.value}');
      print('✅ Added dependency: ${entry.key}: ${entry.value}');
      modified = true;
    }
  }

  if (!devDepsSectionFound) {
    newLines.add('');
    newLines.add('dev_dependencies:');
    for (final entry in devDepsToAdd.entries) {
      newLines.add('  ${entry.key}: ${entry.value}');
      print('✅ Added dev_dependency: ${entry.key}: ${entry.value}');
      modified = true;
    }
  }

  if (modified) {
    pubspecFile.writeAsStringSync(newLines.join('\n'));
    print('\n📦 Running flutter pub get...\n');
    final result = await Process.run('flutter', [
      'pub',
      'get',
    ], runInShell: true);
    if (result.exitCode != 0) {
      print('❌ Error running flutter pub get:');
      print(result.stderr);
      exit(1);
    }
    print('✅ Dependencies installed successfully!\n');
  } else {
    print('⏩ All dependencies already exist.\n');
  }

  // Buat struktur folder
  final dirs = [
    Directory('lib/features'),
    Directory('lib/core/navigation'),
    Directory('lib/widgets'),
    Directory('lib/providers'),
    Directory('lib/models'),
    Directory('.vscode'),
  ];

  for (final dir in dirs) {
    dir.createSync(recursive: true);
    print('✅ Created/Updated directory: ${dir.path}');
  }

  // Buat .vscode/tasks.json
  final tasksFile = File('.vscode/tasks.json');
  tasksFile.writeAsStringSync(defaultTasksJson.trim());
  print('✅ Created/Updated .vscode/tasks.json');

  // Buat main.dart
  final mainFile = File('lib/main.dart');
  mainFile.writeAsStringSync(defaultMainDart.trim());
  print('✅ Created/Updated lib/main.dart');

  print('\n🎉 Initialization complete!');
  print('📌 Next steps:');
  print('   Try: dart generate.dart page:home');
  print('   Or use VS Code Tasks (Ctrl+Shift+P → Tasks: Run Task)');
}
