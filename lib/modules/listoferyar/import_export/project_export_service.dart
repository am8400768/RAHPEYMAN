import '../data/repositories/layer_repository_impl.dart';
import '../data/repositories/project_repository_impl.dart';
import '../data/repositories/rebar_repository_impl.dart';
import 'lisofer_file_format.dart';

class ProjectExportService {
  ProjectExportService({
    ProjectRepository? projectRepository,
    LayerRepository? layerRepository,
    RebarRepository? rebarRepository,
  })  : _projectRepository = projectRepository ?? ProjectRepository(),
        _layerRepository = layerRepository ?? LayerRepository(),
        _rebarRepository = rebarRepository ?? RebarRepository();

  final ProjectRepository _projectRepository;
  final LayerRepository _layerRepository;
  final RebarRepository _rebarRepository;

  Future<String> exportProject(int projectId) async {
    if (projectId <= 0) {
      throw ArgumentError('شناسه پروژه معتبر نیست.');
    }

    final project = await _projectRepository.getById(projectId);
    if (project == null) {
      throw StateError('پروژه پیدا نشد.');
    }

    final nodes = await _layerRepository.getAllByProject(projectId);
    final rebarItems = await _rebarRepository.getByProject(projectId);

    return ListoferyarFileFormat.encodeJson(
      project: project,
      nodes: nodes,
      rebarItems: rebarItems,
    );
  }
}
