// Создаем тип Email, который "под капотом" является обычной строкой (String).
abstract Email(String) {
    // Конструктор, который проверяет валидность email при создании.
    public function new(value:String) {
        if (!~/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}/i.match(value)) {
            throw 'Некорректный формат Email: ${value}';
        }
        this = value;
    }
}

class Demo3 {
    // Эта функция строго типизирована: она принимает ТОЛЬКО Email, а не любую строку.
    static function sendEmail(to:Email, subject:String) {
        trace('Отправка письма на [${to}] с темой "${subject}"');
    }

    static function main() {

        var validEmail:Email = new Email("test@haxe.org");
        sendEmail(validEmail, "Тема 1");

        // А теперь попробуем создать невалидный Email.
        try {
            var invalidEmail:Email = new Email("Ayaya");
            sendEmail(invalidEmail, "Тема 2");
        } catch (e:String) {
            trace('Ошибка: ${e}');
        }

    }
}