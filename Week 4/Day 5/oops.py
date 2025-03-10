#In these class i am going to practise inheritance, polyorphism, method overriding, and polymorphism, abstraction, and encapsulation, 
#constructor, destructor, and getter and setter, shallow copy, deep copy, and class method, static method, and class variable.


class Animal:
    def __init__(self, name):
        self.name = name
    def __str__(self):
        return f"Animal {self.name}"
    def speak(self):
        print(f"Animal {self.name} is speaking")
#Adding method overriding concept and overloading concept
class Dog(Animal):
    def speak(self):
        print(f"Dog {self.name} is barking")
    def __str__(self):
        return f"Dog {self.name}"
    #Adding method overloading concept
    def speak(self, age):
        print(f"Dog {self.name} is barking and {age} years old coming from Method Overloading")
    #Adding method overriding concept
    def speaks(self, age, name):
        return f"Dog {name} is barking and {age} years old"

class Cat(Animal):
    def speak(self):
        print(f"Cat {self.name} is meowing")

class Bird(Animal):
    def speak(self):
        print(f"Bird {self.name} is chirping")

def main():
    dog = Dog("Buddy")
    #dog.speak()
    print(dog.speak(10))
    print(dog)
    print(dog.speaks(10, "Buddy"))
if __name__ == "__main__":
    main()

    ''''
    ? method overloading is not possible in same class
    method overloading & method overwriting is only possible in inheritance but in java it is possible because it carries an instance variable
    
    '''