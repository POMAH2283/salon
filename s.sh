# Создаем структуру папок
$folders = @(
    "lib\core\constants",
    "lib\core\utils", 
    "lib\core\styles",
    "lib\core\themes",
    "lib\core\services",
    "lib\core\data\models",
    "lib\core\data\repositories",
    "lib\core\data\datasources",
    "lib\core\domain\entities",
    "lib\core\domain\repositories", 
    "lib\core\domain\usecases",
    "lib\core\presentation\blocs",
    "lib\core\presentation\cubits",
    "lib\core\presentation\widgets",
    "lib\features\auth\data",
    "lib\features\auth\domain",
    "lib\features\auth\presentation",
    "lib\features\cars\data",
    "lib\features\cars\domain",
    "lib\features\cars\presentation",
    "lib\features\clients\data",
    "lib\features\clients\domain",
    "lib\features\clients\presentation",
    "lib\features\deals\data",
    "lib\features\deals\domain",
    "lib\features\deals\presentation",
    "lib\features\employees\data",
    "lib\features\employees\domain",
    "lib\features\employees\presentation",
    "lib\features\profile\data",
    "lib\features\profile\domain",
    "lib\features\profile\presentation",
    "lib\features\home\data",
    "lib\features\home\domain",
    "lib\features\home\presentation",
    "assets\images",
    "assets\icons"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder
}

# Создаем файлы
$files = @(
    "lib\main.dart",
    "lib\app.dart", 
    "lib\routes.dart",
    "lib\di.dart",
    "lib\core\constants\app_constants.dart",
    "lib\core\constants\api_constants.dart",
    "lib\core\utils\extensions.dart",
    "lib\core\utils\validators.dart",
    "lib\core\styles\app_colors.dart",
    "lib\core\styles\text_styles.dart",
    "lib\core\themes\app_theme.dart",
    "lib\core\services\api_service.dart",
    "lib\core\services\storage_service.dart",
    "lib\core\services\auth_service.dart",
    "lib\features\auth\data\models\login_request.dart",
    "lib\features\auth\data\models\user_model.dart",
    "lib\features\auth\data\repositories\auth_repository_impl.dart",
    "lib\features\auth\domain\entities\user_entity.dart",
    "lib\features\auth\domain\repositories\auth_repository.dart",
    "lib\features\auth\domain\usecases\login_usecase.dart",
    "lib\features\auth\presentation\bloc\auth_bloc.dart",
    "lib\features\auth\presentation\bloc\auth_event.dart",
    "lib\features\auth\presentation\bloc\auth_state.dart",
    "lib\features\auth\presentation\screens\login_screen.dart",
    "lib\features\auth\presentation\widgets\login_form.dart",
    "lib\features\cars\data\models\car_model.dart",
    "lib\features\cars\data\repositories\car_repository_impl.dart",
    "lib\features\cars\domain\entities\car_entity.dart",
    "lib\features\cars\domain\repositories\car_repository.dart",
    "lib\features\cars\domain\usecases\get_cars_usecase.dart",
    "lib\features\cars\presentation\bloc\cars_bloc.dart",
    "lib\features\cars\presentation\bloc\cars_event.dart",
    "lib\features\cars\presentation\bloc\cars_state.dart",
    "lib\features\cars\presentation\screens\cars_list_screen.dart",
    "lib\features\cars\presentation\screens\car_detail_screen.dart",
    "lib\features\cars\presentation\widgets\car_card.dart",
    "lib\features\cars\presentation\widgets\car_filter.dart"
)

foreach ($file in $files) {
    New-Item -ItemType File -Force -Path $file
}

Write-Host "Структура проекта создана успешно!" -ForegroundColor Green