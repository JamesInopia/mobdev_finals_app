// @dart=3.6
// ignore_for_file: type=lint
// build_runner >=2.4.16
import 'dart:io' as _io;
import 'package:build_runner/src/build_plan/builder_factories.dart'
    as _build_runner;
import 'package:build_runner/src/bootstrap/processes.dart' as _build_runner;
import 'package:mockito/src/builder.dart' as _i1;
import 'package:source_gen/builder.dart' as _i2;
import 'package:stacked_generator/builder.dart' as _i3;

final _builderFactories = _build_runner.BuilderFactories(
  {
    'mockito:mockBuilder': [_i1.buildMocks],
    'source_gen:combining_builder': [_i2.combiningBuilder],
    'stacked_generator:stackedBottomsheetGenerator': [
      _i3.stackedBottomsheetGenerator
    ],
    'stacked_generator:stackedDialogGenerator': [_i3.stackedDialogGenerator],
    'stacked_generator:stackedFormGenerator': [_i3.stackedFormGenerator],
    'stacked_generator:stackedLocatorGenerator': [_i3.stackedLocatorGenerator],
    'stacked_generator:stackedLoggerGenerator': [_i3.stackedLoggerGenerator],
    'stacked_generator:stackedRouterGenerator': [_i3.stackedRouterGenerator],
  },
  postProcessBuilderFactories: {
    'source_gen:part_cleanup': _i2.partCleanup,
  },
);
void main(List<String> args) async {
  _io.exitCode = await _build_runner.ChildProcess.run(
    args,
    _builderFactories,
  )!;
}
