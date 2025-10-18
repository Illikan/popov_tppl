import json

class Point:
    def __init__(self, x: int, y: int) -> None:
        
        if not isinstance(x, int) or not isinstance(y, int):
            raise TypeError
        
        self.x = x
        self.y = y

    def __add__(self, other: "Point") -> "Point":
        return Point(self.x + other.x, self.y + other.y)
    def __iadd__(self, other: "Point") -> "Point":
        return Point(self.x + other.x, self.y + other.y)
    
    
    def __eq__(self, other: "Point") -> bool:
        return self.x == other.x and self.y == other.y
    
    def __sub__(self, other: "Point") -> "Point":
        return Point(self.x - other.x, self.y - other.y)
    
    def __neg__(self) -> "Point":
        return Point(-self.x, -self.y)
    
    def distance_to(self, other: "Point") -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5
    
    def __str__(self):
        return f"{self.__class__.__name__}({self.x}, {self.y})"
    
    def __repr__(self):
        return str(self)
    
    def is_center(self) -> bool:
        return self.x == 0 and self.y == 0
    
    def to_json(self) -> str:
        return json.dumps(self.__dict__)
    
    @staticmethod
    def from_json(cls, s:str) -> "Point":
       js = json.loads(s)
       return cls(js["x"], js["y"])