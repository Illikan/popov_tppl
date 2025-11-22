class Calculator {
    private var value:Float;

    public function new(initialValue:Float) {
        this.value = initialValue;
    }

    public function add(n:Float):Void {
        this.value += n;
    }

    public function multiply(n:Float):Void {
        this.value *= n;
    }

    public function getResult():Float {
        return this.value;
    }
}

class Main {
    static function main() {
        var calc = new Calculator(10);
        trace("Начальное значение: 10");

        calc.add(5);
        trace("добавили 5");

        calc.multiply(3);
        trace("умножили на 3");

        trace("---");
        trace('Итоговый результат: ${calc.getResult()}');
    }
}
// haxe -cp src -main Main -js main.js
// node main.js

//haxe -cp src -main Main -python main.py
//python main.py