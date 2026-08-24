import '../data/repositories/layer_repository_impl.dart';
import '../data/repositories/project_repository_impl.dart';
import '../data/repositories/rebar_repository_impl.dart';
import '../domain/models/project.dart';
import '../domain/models/project_node.dart';
import '../domain/models/rebar_item.dart';
import 'rebar_report_service.dart';

class ProjectReportService {
  ProjectReportService({
    ProjectRepository? projectRepository,
    LayerRepository? layerRepository,
    RebarRepository? rebarRepository,
    RebarReportService? rebarReportService,
  })  : _projectRepository = projectRepository ?? ProjectRepository(),
        _layerRepository = layerRepository ?? LayerRepository(),
        _rebarRepository = rebarRepository ?? RebarRepository(),
        _rebarReportService = rebarReportService ?? const RebarReportService();

  final ProjectRepository _projectRepository;
  final LayerRepository _layerRepository;
  final RebarRepository _rebarRepository;
  final RebarReportService _rebarReportService;

  Future<ListoferyarProjectReport> build(int projectId) async {
    if (projectId <= 0) {
      throw ArgumentError('شناسه پروژه معتبر نیست.');
    }

    final project = await _projectRepository.getById(projectId);
    if (project == null) {
      throw StateError('پروژه پیدا نشد.');
    }

    final nodes = await _layerRepository.getAllByProject(projectId);
    final rebarItems = await _rebarRepository.getByProject(projectId);

    return ListoferyarProjectReport(
      project: project,
      nodes: nodes,
      rebarItems: rebarItems,
      byDiameter: _rebarReportService.summarizeByDiameter(rebarItems),
      byUsage: _rebarReportService.summarizeByUsage(rebarItems),
    );
  }
}

class ListoferyarProjectReport {
  const ListoferyarProjectReport({
    required this.project,
    required this.nodes,
    required this.rebarItems,
    required this.byDiameter,
    required this.byUsage,
  });

  final ListoferyarProject project;
  final List<ListoferyarProjectNode> nodes;
  final List<ListoferyarRebarItem> rebarItems;
  final List<RebarDiameterSummary> byDiameter;
  final List<RebarUsageSummary> byUsage;

  int get totalQuantity =>
      rebarItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalLength =>
      rebarItems.fold(0, (sum, item) => sum + item.totalLength);

  double get totalWeight =>
      rebarItems.fold(0, (sum, item) => sum + item.totalWeight);
}
