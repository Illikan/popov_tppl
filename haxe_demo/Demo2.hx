@:build(Macro.addBuildInfo())
class AppInfo {}

class Demo2 {
    static function main() {
        trace("\n--- Демо 2: Макросы ---");

        var app = new AppInfo();

        // Этих полей нет в исходном коде AppInfo
        // Их добавил макрос во время компиляции
        trace('Версия сборки: ${app.buildVersion}');
        trace('Время сборки: ${app.buildTime}');
    }
}