// src/Macro.hx
import haxe.macro.Context;
import haxe.macro.Expr;

class Macro {
    public static function addBuildInfo() {
        // Получаем поля текущего класса (список будет пуст)
        var fields = Context.getBuildFields();

        // 1. Генерируем поле с версией
        var versionField = {
            name: "buildVersion",
            access: [Access.APublic],
            kind: FieldType.FVar(macro:String, macro "1.0.0-alpha"),
            pos: Context.currentPos()
        };

        // 2. Генерируем поле с датой компиляции
        var date = Date.now().toString();
        var dateField = {
            name: "buildTime",
            access: [Access.APublic],
            kind: FieldType.FVar(macro:String, macro $v{date}),
            pos: Context.currentPos()
        };

        // 3. ГЕНЕРИРУЕМ ПУСТОЙ КОНСТРУКТОР
        var constructorField = {
            name: "new",
            access: [Access.APublic],
            kind: FieldType.FFun({
                args: [],
                ret: null, // Конструктор ничего не возвращает
                expr: macro {} // Пустое тело функции: {}
            }),
            pos: Context.currentPos()
        };

        // Добавляем все сгенерированные поля к классу
        fields.push(versionField);
        fields.push(dateField);
        fields.push(constructorField); // <--- Вот и он!

        // Возвращаем полный список полей для нового тела класса
        return fields;
    }
}