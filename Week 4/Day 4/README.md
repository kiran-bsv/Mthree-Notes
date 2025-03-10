- [**OOPS**](#oops)
  - [**1. Class Definition \& Object Creation**](#1-class-definition--object-creation)
    - [**Python Code**](#python-code)
    - [**C++ Equivalent Code**](#c-equivalent-code)
  - [**2. Python vs. C++ Key Differences**](#2-python-vs-c-key-differences)
  - [**3. Summary of Key Points**](#3-summary-of-key-points)
  - [**Inheritance**](#inheritance)
  - [**1. Class Inheritance \& Object Creation**](#1-class-inheritance--object-creation)
    - [**Python Code**](#python-code-1)
    - [**C++ Equivalent Code**](#c-equivalent-code-1)
  - [**2. Python vs. C++ Key Differences in Inheritance**](#2-python-vs-c-key-differences-in-inheritance)
  - [**3. Summary of Key Points**](#3-summary-of-key-points-1)
  - [**Encapsulation in Python vs. C++**](#encapsulation-in-python-vs-c)
  - [**Encapsulation**](#encapsulation)
  - [**Key Differences: Python vs. C++ Encapsulation**](#key-differences-python-vs-c-encapsulation)
    - [**Polymorphism**](#polymorphism)
    - [**Abstraction in Python and C++**](#abstraction-in-python-and-c)
  - [**Key Differences: Python vs. C++**](#key-differences-python-vs-c)
    - [**Properties and Descriptors**](#properties-and-descriptors)
  - [**Python Implementation using `@property`**](#python-implementation-using-property)
  - [**C++ Implementation using Getters and Setters**](#c-implementation-using-getters-and-setters)
  - [**Key Differences: Python vs. C++**](#key-differences-python-vs-c-1)
- [**CLASS AND STATIC METHODS**](#class-and-static-methods)
  - [**Python Implementation**](#python-implementation)
  - [**C++ Implementation**](#c-implementation)
    - [**Key Differences:**](#key-differences)
- [**MAGIC METHODS (DUNDER METHODS in Python) \& OPERATOR OVERLOADING**](#magic-methods-dunder-methods-in-python--operator-overloading)
  - [**Python Implementation**](#python-implementation-1)
  - [**C++ Implementation**](#c-implementation-1)
    - [**Key Differences:**](#key-differences-1)
  - [**Metaclasses in Python and Their Equivalent in C++**](#metaclasses-in-python-and-their-equivalent-in-c)
    - [**Concept Overview**](#concept-overview)
    - [**Python: Metaclass Example**](#python-metaclass-example)
      - [**Singleton Metaclass (Restricts a Class to a Single Instance)**](#singleton-metaclass-restricts-a-class-to-a-single-instance)
      - [**Logging Metaclass (Adds Logging to All Methods)**](#logging-metaclass-adds-logging-to-all-methods)
    - [**C++ Equivalent of Python Metaclasses**](#c-equivalent-of-python-metaclasses)
      - [**Singleton Pattern in C++**](#singleton-pattern-in-c)
      - [**CRTP for Logging (Metaclass-like Behavior)**](#crtp-for-logging-metaclass-like-behavior)
    - [**Comparison: Python vs C++**](#comparison-python-vs-c)
    - [**Summary**](#summary)
  - [**Advanced Design Patterns: Explanation \& Comparison (Python vs. C++)**](#advanced-design-patterns-explanation--comparison-python-vs-c)
  - [**1. Singleton Pattern**](#1-singleton-pattern)
    - [**Concept**](#concept)
    - [**Python Implementation**](#python-implementation-2)
    - [**C++ Implementation**](#c-implementation-2)
    - [**Python vs. C++ Comparison**](#python-vs-c-comparison)
  - [**2. Factory Pattern**](#2-factory-pattern)
    - [**Concept**](#concept-1)
    - [**Python Implementation**](#python-implementation-3)
    - [**C++ Implementation**](#c-implementation-3)
    - [**Python vs. C++ Comparison**](#python-vs-c-comparison-1)
  - [**3. Observer Pattern**](#3-observer-pattern)
    - [**Concept**](#concept-2)
    - [**Python Implementation**](#python-implementation-4)
    - [**C++ Implementation**](#c-implementation-4)
    - [**Python vs. C++ Comparison**](#python-vs-c-comparison-2)


# **OOPS**
## **1. Class Definition & Object Creation**

### **Python Code**
```python
class Dog:
    species = "Canis familiaris"  # Class attribute shared by all instances
    
    def __init__(self, name, age):
        """Constructor - Initializes an instance of Dog."""
        self.name = name  # Instance attribute
        self.age = age
    
    def bark(self):
        """Instance method - defines behavior."""
        return f"{self.name} says Woof!"
    
    def get_info(self):
        """Returns dog's information."""
        return f"{self.name} is {self.age} years old."

# Creating objects (instances)
fido = Dog("Fido", 3)
bella = Dog("Bella", 5)

# Accessing attributes and methods
print(fido.bark())      # Output: Fido says Woof!
print(bella.get_info()) # Output: Bella is 5 years old.
```

### **C++ Equivalent Code**
```cpp
#include <iostream>
#include <string>
using namespace std;

class Dog {
public:
    static string species;  // Class attribute shared by all instances
    
    string name;  // Instance attribute
    int age;

    // Constructor - Initializes an instance of Dog
    Dog(string n, int a) {
        name = n;
        age = a;
    }

    // Instance method - defines behavior
    string bark() {
        return name + " says Woof!";
    }

    // Returns dog's information
    string getInfo() {
        return name + " is " + to_string(age) + " years old.";
    }
};

// Define static class attribute outside the class
string Dog::species = "Canis familiaris";

int main() {
    // Creating objects (instances)
    Dog fido("Fido", 3);
    Dog bella("Bella", 5);

    // Accessing attributes and methods
    cout << fido.bark() << endl;      // Output: Fido says Woof!
    cout << bella.getInfo() << endl;  // Output: Bella is 5 years old.

    return 0;
}
```

---

## **2. Python vs. C++ Key Differences**

| Feature              | Python | C++ |
|----------------------|--------|------|
| **Class Definition** | Uses `class Dog:` | Uses `class Dog {}` |
| **Class Attribute** | Defined inside class (`species = "Canis familiaris"`) | Defined as `static` and declared outside class (`static string species;`) |
| **Constructor** | `__init__()` | Named same as class (`Dog()`) |
| **Instance Attributes** | `self.name = name` | Uses constructor initialization (`name = n;`) |
| **Method Definition** | Uses `def` and `self` | Uses regular functions inside class |
| **Method Call** | `dog.bark()` | `dog.bark()` |
| **Static/Class Variables** | Can be accessed via `ClassName.attribute` or `self.attribute` | Must be declared as `static` and defined outside class |
| **Memory Management** | Automatic (Garbage Collection) | Manual (`new` and `delete` required for dynamic allocation) |
| **Printing Output** | `print()` function | `cout <<` with `<< endl;` |

---

## **3. Summary of Key Points**
1. **Class & Object Syntax**  
   - Python: Uses `class Dog:` and `__init__()` for initialization.  
   - C++: Uses `class Dog {}` and a constructor method with the same name.

2. **Self vs. `this` Pointer**  
   - Python: Uses `self` to refer to instance variables and methods.  
   - C++: Uses implicit `this` pointer inside methods.

3. **Memory Management**  
   - Python: Uses **Garbage Collection (GC)** to manage memory.  
   - C++: Uses manual allocation (`new` / `delete` for dynamic memory).

4. **Class and Static Variables**  
   - Python: Defined inside the class body.  
   - C++: Defined inside the class but **must be initialized outside**.

---

This comparison shows that **Python OOP is more flexible and concise**, whereas **C++ provides more control over memory and performance**.

---

## **Inheritance**  

Inheritance is a fundamental concept in Object-Oriented Programming (OOP) that allows a **child class (subclass)** to inherit attributes and methods from a **parent class (base class)**. This promotes **code reuse** and **hierarchical relationships**.

---

## **1. Class Inheritance & Object Creation**  

### **Python Code**
```python
class Pet:
    """A base class for all pets."""
    
    def __init__(self, name, age):
        """Constructor - Initializes a Pet object."""
        self.name = name
        self.age = age
    
    def speak(self):
        """A generic sound method (to be overridden)."""
        return "Some generic pet sound"
    
    def __str__(self):
        """String representation of the pet."""
        return f"{self.name}, age {self.age}"


class Cat(Pet):  # Cat inherits from Pet
    """A class representing a cat, inheriting from Pet."""
    
    species = "Felis catus"
    
    def __init__(self, name, age, color):
        """Constructor - Initializes a Cat object."""
        super().__init__(name, age)  # Calls parent constructor
        self.color = color  # Cat-specific attribute
    
    def speak(self):
        """Overrides speak method from parent class."""
        return f"{self.name} says Meow!"
    
    def purr(self):
        """A Cat-specific method."""
        return f"{self.name} purrs contentedly."


# Creating an instance of Cat
whiskers = Cat("Whiskers", 4, "gray")

# Checking inheritance
print(isinstance(whiskers, Cat))   # Output: True
print(isinstance(whiskers, Pet))   # Output: True

# Accessing attributes and methods
print(whiskers.name)     # Output: Whiskers (inherited from Pet)
print(whiskers.color)    # Output: gray (specific to Cat)
print(whiskers)          # Output: Whiskers, age 4 (__str__ method from Pet)
print(whiskers.speak())  # Output: Whiskers says Meow! (overridden method)
print(whiskers.purr())   # Output: Whiskers purrs contentedly. (Cat-specific method)
```

---

### **C++ Equivalent Code**
```cpp
#include <iostream>
#include <string>
using namespace std;

class Pet {
public:
    string name;
    int age;

    // Constructor
    Pet(string n, int a) {
        name = n;
        age = a;
    }

    // Virtual method for sound (to be overridden)
    virtual string speak() {
        return "Some generic pet sound";
    }

    // String representation of Pet
    string getInfo() {
        return name + ", age " + to_string(age);
    }
};

// Cat class inherits from Pet
class Cat : public Pet {
public:
    string color;
    static string species; // Class attribute

    // Constructor - Calls base class constructor
    Cat(string n, int a, string c) : Pet(n, a) {
        color = c;
    }

    // Overriding speak method
    string speak() override {
        return name + " says Meow!";
    }

    // Cat-specific method
    string purr() {
        return name + " purrs contentedly.";
    }
};

// Define static class attribute
string Cat::species = "Felis catus";

int main() {
    // Creating an instance of Cat
    Cat whiskers("Whiskers", 4, "gray");

    // Checking inheritance
    cout << whiskers.getInfo() << endl; // Output: Whiskers, age 4
    cout << whiskers.speak() << endl;   // Output: Whiskers says Meow!
    cout << whiskers.purr() << endl;    // Output: Whiskers purrs contentedly.

    return 0;
}
```

---

## **2. Python vs. C++ Key Differences in Inheritance**

| Feature            | Python | C++ |
|--------------------|--------|------|
| **Base Class Definition** | `class Pet:` | `class Pet {}` |
| **Subclass Definition** | `class Cat(Pet):` | `class Cat : public Pet {}` |
| **Constructor Call in Subclass** | `super().__init__(name, age)` | `Cat(string n, int a, string c) : Pet(n, a)` |
| **Method Overriding** | Directly override `speak()` | Use `virtual` keyword in base class and `override` in subclass |
| **Static/Class Variable** | Defined inside class (`species = "Felis catus"`) | Declared inside class but defined outside (`string Cat::species = "Felis catus";`) |
| **Access Specifiers** | Default is `public` | Must explicitly use `public`, `private`, or `protected` |
| **Printing Output** | Uses `print()` function | Uses `cout <<` with `endl;` |

---

## **3. Summary of Key Points**
1. **Inheritance Syntax**  
   - Python: `class Cat(Pet):`  
   - C++: `class Cat : public Pet {}`  

2. **Calling Parent Constructor**  
   - Python: Uses `super().__init__()`  
   - C++: Uses `: ParentConstructor()` initializer list.

3. **Method Overriding**  
   - Python: Simply define the method with the same name.  
   - C++: Parent class method must be `virtual`, and subclass must use `override`.

4. **Class Attributes**  
   - Python: Defined inside the class and shared by all instances.  
   - C++: Declared as `static` and must be **defined outside** the class.

5. **Access Control**  
   - Python: **Everything is public by default** (but uses `_protected` and `__private` conventions).  
   - C++: **Explicit access control (`public`, `protected`, `private`)**.

---

## **Encapsulation in Python vs. C++**

Encapsulation is a fundamental principle of Object-Oriented Programming (OOP) that restricts direct access to certain details of an object, ensuring better data protection and controlled interaction through public methods.

---

## **Encapsulation**
Python uses **conventions** to enforce encapsulation:
- **Public attributes**: Can be accessed anywhere.
- **Protected attributes** (`_attribute`): Should be accessed only within the class and subclasses (not enforced).
- **Private attributes** (`__attribute`): Cannot be accessed directly outside the class (Python applies **name mangling**).

```python
class BankAccount:
    """A class representing a bank account with encapsulation."""
    
    def __init__(self, owner, initial_balance=0):
        self.owner = owner
        self.__balance = initial_balance  # Private attribute
        self._transaction_count = 0      # Protected attribute
    
    def deposit(self, amount):
        """Deposit money into the account."""
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        
        self.__balance += amount
        self._transaction_count += 1
        return self.__balance
    
    def withdraw(self, amount):
        """Withdraw money from the account."""
        if amount <= 0:
            raise ValueError("Withdrawal amount must be positive")
        if amount > self.__balance:
            raise ValueError("Insufficient funds")
        
        self.__balance -= amount
        self._transaction_count += 1
        return self.__balance
    
    def get_balance(self):
        """Get the current balance."""
        return self.__balance

    def get_transaction_count(self):
        """Get the number of transactions."""
        return self._transaction_count


# Using the class
account = BankAccount("Alice", 500)
print(account.deposit(300))      # Output: 800
print(account.withdraw(200))     # Output: 600
print(account.get_balance())     # Output: 600

# Accessing private attributes directly raises an error
# print(account.__balance)  # AttributeError

# Python name mangling: The private variable is stored as _BankAccount__balance
print(account._BankAccount__balance)  # Output: 600 (not recommended)
```

---

C++ uses **access specifiers** to enforce encapsulation:
- `public`: Accessible from anywhere.
- `protected`: Accessible within the class and subclasses.
- `private`: Accessible only within the class.

```cpp
#include <iostream>
using namespace std;

class BankAccount {
private:
    double balance; // Private attribute
    int transaction_count; // Private attribute

protected:
    string owner; // Protected attribute

public:
    // Constructor
    BankAccount(string owner_name, double initial_balance = 0) {
        owner = owner_name;
        balance = initial_balance;
        transaction_count = 0;
    }

    // Deposit method
    void deposit(double amount) {
        if (amount <= 0) {
            cout << "Deposit amount must be positive" << endl;
            return;
        }
        balance += amount;
        transaction_count++;
    }

    // Withdraw method
    void withdraw(double amount) {
        if (amount <= 0) {
            cout << "Withdrawal amount must be positive" << endl;
            return;
        }
        if (amount > balance) {
            cout << "Insufficient funds" << endl;
            return;
        }
        balance -= amount;
        transaction_count++;
    }

    // Public method to get balance
    double getBalance() const {
        return balance;
    }

    // Public method to get transaction count
    int getTransactionCount() const {
        return transaction_count;
    }
};

// Using the class
int main() {
    BankAccount account("Alice", 500);
    
    account.deposit(300);
    cout << "Balance after deposit: " << account.getBalance() << endl; // Output: 800
    
    account.withdraw(200);
    cout << "Balance after withdrawal: " << account.getBalance() << endl; // Output: 600

    cout << "Total transactions: " << account.getTransactionCount() << endl; // Output: 2

    // Trying to access private attribute directly will cause a compilation error
    // cout << account.balance; // Error: balance is private

    return 0;
}
```

---

## **Key Differences: Python vs. C++ Encapsulation**
| Feature        | Python | C++ |
|---------------|--------|-----|
| **Access Control** | Conventions (`_protected`, `__private`) | `private`, `protected`, `public` |
| **Strictness** | Name mangling (`__attribute` becomes `_Class__attribute`) | Enforced at the compiler level |
| **Encapsulation Violation** | Can access private members using `_Class__attribute` (not recommended) | Cannot access private members directly (compilation error) |
| **Usage of Getters/Setters** | Common but not required | More common due to strict private attributes |
| **Flexibility** | More dynamic | More rigid (ensures stricter encapsulation) |

---

- Python **suggests** encapsulation using naming conventions but does not enforce it strictly.
- C++ **enforces** encapsulation at the compiler level, preventing direct access to private attributes.
- Both languages use **getter/setter methods** to interact with private data safely.

Encapsulation ensures **data security**, **controlled access**, and **maintainability** in object-oriented programming. 

---

### **Polymorphism**  

Polymorphism allows different classes to define the same method name while providing their own specific implementations. Below is how the concept of polymorphism works in **Python** and **C++**.

---

Python uses polymorphism through method overriding and duck typing.

```python
class Animal:
    """Base class for all animals."""
    
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        """The sound the animal makes (to be overridden by subclasses)."""
        raise NotImplementedError("Subclasses must implement this method")
    
    def introduce(self):
        """The animal introduces itself."""
        return f"I am {self.name} and I {self.speak()}"


class Dog(Animal):
    """A class representing a dog."""
    
    def speak(self):
        return "bark"


class Cat(Animal):
    """A class representing a cat."""
    
    def speak(self):
        return "meow"


class Duck(Animal):
    """A class representing a duck."""
    
    def speak(self):
        return "quack"


# Polymorphism in action
def animal_sound(animal):
    return animal.speak()


# Creating different animal objects
fido = Dog("Fido")
whiskers = Cat("Whiskers")
donald = Duck("Donald")

# Using polymorphism
print(animal_sound(fido))      # Output: bark
print(animal_sound(whiskers))  # Output: meow
print(animal_sound(donald))    # Output: quack

print(fido.introduce())       # Output: I am Fido and I bark
print(whiskers.introduce())   # Output: I am Whiskers and I meow
print(donald.introduce())     # Output: I am Donald and I quack
```

---

C++ implements polymorphism using **virtual functions**.

```cpp
#include <iostream>
#include <string>
using namespace std;

class Animal {
protected:
    string name;
public:
    Animal(string n) : name(n) {}
    virtual string speak() = 0; // Pure virtual function
    string introduce() {
        return "I am " + name + " and I " + speak();
    }
};

class Dog : public Animal {
public:
    Dog(string n) : Animal(n) {}
    string speak() override {
        return "bark";
    }
};

class Cat : public Animal {
public:
    Cat(string n) : Animal(n) {}
    string speak() override {
        return "meow";
    }
};

class Duck : public Animal {
public:
    Duck(string n) : Animal(n) {}
    string speak() override {
        return "quack";
    }
};

// Polymorphic function
void animalSound(Animal &animal) {
    cout << animal.speak() << endl;
}

int main() {
    Dog fido("Fido");
    Cat whiskers("Whiskers");
    Duck donald("Donald");

    // Using polymorphism
    animalSound(fido);      // Output: bark
    animalSound(whiskers);  // Output: meow
    animalSound(donald);    // Output: quack

    // Using overridden introduce method
    cout << fido.introduce() << endl;       // Output: I am Fido and I bark
    cout << whiskers.introduce() << endl;   // Output: I am Whiskers and I meow
    cout << donald.introduce() << endl;     // Output: I am Donald and I quack

    return 0;
}
```

---

| Feature         | Python | C++ |
|----------------|--------|------|
| Virtual Methods | All methods are virtual by default | Need `virtual` keyword |
| Abstract Methods | Use `raise NotImplementedError` | Use pure virtual functions (`= 0`) |
| Dynamic Dispatch | Automatic | Requires pointer or reference for polymorphism |
| No need for explicit `override` | Uses `override` keyword for clarity |

Both languages allow polymorphism, but **Python** provides more flexibility with dynamic typing, while **C++** requires explicit virtual function definitions.

---


### **Abstraction in Python and C++**  

**Abstraction** is the process of hiding implementation details and exposing only the essential functionalities. It allows defining a common interface for multiple derived classes.

---

Python implements abstraction using the `ABC` module and the `@abstractmethod` decorator.

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    """An abstract base class for geometric shapes."""
    
    @abstractmethod
    def area(self):
        pass
    
    @abstractmethod
    def perimeter(self):
        pass
    
    def describe(self):
        """Return a description of the shape."""
        return f"This shape has an area of {self.area()} and a perimeter of {self.perimeter()}"


class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius
    
    def area(self):
        return 3.14159 * self.radius ** 2
    
    def perimeter(self):
        return 2 * 3.14159 * self.radius


class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self):
        return self.width * self.height
    
    def perimeter(self):
        return 2 * (self.width + self.height)


# Creating shape objects
circle = Circle(5)
rectangle = Rectangle(4, 6)

# Using the common interface
print(circle.area())        # Output: 78.53975
print(rectangle.area())     # Output: 24
print(circle.describe())    # Output: This shape has an area of 78.53975 and a perimeter of 31.4159
print(rectangle.describe()) # Output: This shape has an area of 24 and a perimeter of 20
```

---

C++ implements abstraction using **pure virtual functions**.

```cpp
#include <iostream>
using namespace std;

class Shape {
public:
    virtual double area() = 0;     // Pure virtual function
    virtual double perimeter() = 0; // Pure virtual function

    void describe() {
        cout << "This shape has an area of " << area() 
             << " and a perimeter of " << perimeter() << endl;
    }
};

class Circle : public Shape {
private:
    double radius;
public:
    Circle(double r) : radius(r) {}
    
    double area() override {
        return 3.14159 * radius * radius;
    }
    
    double perimeter() override {
        return 2 * 3.14159 * radius;
    }
};

class Rectangle : public Shape {
private:
    double width, height;
public:
    Rectangle(double w, double h) : width(w), height(h) {}

    double area() override {
        return width * height;
    }

    double perimeter() override {
        return 2 * (width + height);
    }
};

int main() {
    Circle circle(5);
    Rectangle rectangle(4, 6);

    cout << "Circle Area: " << circle.area() << endl;        // Output: 78.53975
    cout << "Rectangle Area: " << rectangle.area() << endl;  // Output: 24
    
    circle.describe();      // Output: This shape has an area of 78.53975 and a perimeter of 31.4159
    rectangle.describe();   // Output: This shape has an area of 24 and a perimeter of 20

    return 0;
}
```

---

## **Key Differences: Python vs. C++**
| Feature         | Python | C++ |
|----------------|--------|------|
| Abstract Class | Uses `ABC` module | Uses pure virtual functions |
| Abstract Method | `@abstractmethod` decorator | `= 0` in virtual function |
| Instantiation | Cannot instantiate abstract class | Cannot instantiate abstract class |
| Enforcement | Checked at runtime | Checked at compile time |

Both languages support abstraction effectively, but **Python** uses dynamic typing, while **C++** enforces type safety at compile time.

---

### **Properties and Descriptors**  

**Properties** allow controlling access to class attributes by defining custom getter, setter, and deleter methods.  

---

## **Python Implementation using `@property`**
Python uses **property decorators** (`@property`, `@<attr>.setter`, `@<attr>.deleter`) to control attribute access.

```python
class Temperature:
    """A class representing a temperature with validation."""
    
    def __init__(self, celsius=0):
        """Initialize a Temperature object."""
        self.celsius = celsius  # Calls the setter method
    
    @property
    def celsius(self):
        """Getter for Celsius temperature."""
        return self._celsius
    
    @celsius.setter
    def celsius(self, value):
        """Setter for Celsius temperature with validation."""
        if value < -273.15:
            raise ValueError("Temperature cannot be below absolute zero")
        self._celsius = value
    
    @property
    def fahrenheit(self):
        """Getter for Fahrenheit temperature."""
        return self.celsius * 9/5 + 32
    
    @fahrenheit.setter
    def fahrenheit(self, value):
        """Setter for Fahrenheit temperature."""
        self.celsius = (value - 32) * 5/9


# Using properties
temp = Temperature(25)

# Accessing properties
print(temp.celsius)     # Output: 25
print(temp.fahrenheit)  # Output: 77.0

# Setting properties
temp.celsius = 30
print(temp.fahrenheit)  # Output: 86.0

temp.fahrenheit = 68
print(temp.celsius)     # Output: 20.0

# Validation
try:
    temp.celsius = -300  # Raises ValueError
except ValueError as e:
    print(f"Error: {e}")  # Output: Error: Temperature cannot be below absolute zero
```

---

## **C++ Implementation using Getters and Setters**
C++ does not have built-in properties like Python, but we can use **getter and setter methods**.

```cpp
#include <iostream>
using namespace std;

class Temperature {
private:
    double celsius;

public:
    // Constructor
    Temperature(double c = 0) { setCelsius(c); }

    // Getter for Celsius
    double getCelsius() { return celsius; }

    // Setter for Celsius with validation
    void setCelsius(double value) {
        if (value < -273.15) {
            throw invalid_argument("Temperature cannot be below absolute zero");
        }
        celsius = value;
    }

    // Getter for Fahrenheit
    double getFahrenheit() { return celsius * 9 / 5 + 32; }

    // Setter for Fahrenheit
    void setFahrenheit(double value) {
        setCelsius((value - 32) * 5 / 9);
    }
};

int main() {
    try {
        Temperature temp(25);

        // Accessing properties
        cout << "Celsius: " << temp.getCelsius() << endl;       // Output: 25
        cout << "Fahrenheit: " << temp.getFahrenheit() << endl; // Output: 77

        // Setting properties
        temp.setCelsius(30);
        cout << "Updated Fahrenheit: " << temp.getFahrenheit() << endl; // Output: 86

        temp.setFahrenheit(68);
        cout << "Updated Celsius: " << temp.getCelsius() << endl; // Output: 20

        // Validation
        temp.setCelsius(-300);  // Throws exception
    } catch (const exception &e) {
        cout << "Error: " << e.what() << endl;
    }

    return 0;
}
```

---

## **Key Differences: Python vs. C++**
| Feature      | Python (`@property`) | C++ (Getters & Setters) |
|-------------|-----------------|-------------------|
| Built-in Properties | Yes (`@property`) | No, must use methods |
| Direct Attribute Access | Allowed via `@property` | Requires explicit methods |
| Validation | Easily integrated | Implemented manually |
| Read-Only Property | Possible with just `@property` | Possible by omitting the setter |
| Exception Handling | `raise ValueError` | `throw invalid_argument` |

Both approaches achieve the same goal, but **Python provides a more intuitive way** with built-in properties, whereas **C++ requires explicit getter and setter methods**.

---

Here’s a comparison of **class methods, static methods, and magic methods** in **Python** and **C++**, maintaining the style you used:  

---

# **CLASS AND STATIC METHODS**  

## **Python Implementation**  

```python
class MathOperations:
    """A class demonstrating class and static methods."""
    
    pi = 3.14159  # Class variable
    
    def __init__(self, value):
        self.value = value

    # Class method - works with the class itself
    @classmethod
    def circle_area(cls, radius):
        return cls.pi * radius ** 2

    # Static method - doesn't depend on class or instance
    @staticmethod
    def is_positive(x):
        return x > 0


# Usage
print(MathOperations.circle_area(5))  # Output: 78.53975
print(MathOperations.is_positive(-3))  # Output: False
```

## **C++ Implementation**  

```cpp
#include <iostream>
using namespace std;

class MathOperations {
public:
    static constexpr double pi = 3.14159;  // Static class variable

    // Static method - equivalent to Python's @staticmethod
    static bool isPositive(int x) {
        return x > 0;
    }

    // Class method equivalent (C++ doesn't have @classmethod, but we use static)
    static double circleArea(double radius) {
        return pi * radius * radius;
    }
};

// Usage
int main() {
    cout << MathOperations::circleArea(5) << endl;  // Output: 78.53975
    cout << MathOperations::isPositive(-3) << endl; // Output: 0 (false)
}
```

### **Key Differences:**
1. **Python:** Uses `@classmethod` and `@staticmethod` explicitly.  
2. **C++:** Uses `static` keyword for both static and class-level methods.  
3. **Class Variables:** Python allows `cls.variable`, whereas C++ uses `static constexpr`.  

---

# **MAGIC METHODS (DUNDER METHODS in Python) & OPERATOR OVERLOADING**  

## **Python Implementation**  

```python
class Vector:
    """A 2D vector class with operator overloading."""
    
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return Vector(self.x + other.x, self.y + other.y)

    def __mul__(self, scalar):
        return Vector(self.x * scalar, self.y * scalar)

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

    def __str__(self):
        return f"Vector({self.x}, {self.y})"


# Usage
v1 = Vector(3, 4)
v2 = Vector(1, 2)
v3 = v1 + v2
print(v3)         # Output: Vector(4, 6)
print(v1 * 2)     # Output: Vector(6, 8)
print(v1 == v2)   # Output: False
```

---

## **C++ Implementation**  

```cpp
#include <iostream>
using namespace std;

class Vector {
public:
    int x, y;

    Vector(int x, int y) : x(x), y(y) {}

    // Operator overloading for addition
    Vector operator+(const Vector& other) {
        return Vector(x + other.x, y + other.y);
    }

    // Operator overloading for multiplication
    Vector operator*(int scalar) {
        return Vector(x * scalar, y * scalar);
    }

    // Overloading equality operator
    bool operator==(const Vector& other) {
        return x == other.x && y == other.y;
    }

    // Print method
    void print() {
        cout << "Vector(" << x << ", " << y << ")" << endl;
    }
};

// Usage
int main() {
    Vector v1(3, 4), v2(1, 2);
    Vector v3 = v1 + v2;
    
    v3.print();    // Output: Vector(4, 6)
    (v1 * 2).print(); // Output: Vector(6, 8)
    cout << (v1 == v2) << endl; // Output: 0 (false)
}
```

---

### **Key Differences:**
1. **Python:** Uses magic methods like `__add__`, `__mul__`, `__eq__`, and `__str__`.  
2. **C++:** Uses operator overloading (`operator+`, `operator*`, `operator==`).  
3. **Printing Objects:** Python uses `__str__`, while C++ uses a `print()` function or overloads `operator<<`.  

---

## **Metaclasses in Python and Their Equivalent in C++**

### **Concept Overview**
Metaclasses in Python are "classes of classes," meaning they define how classes behave. They allow customization of class creation, such as enforcing patterns (e.g., Singleton) or adding behaviors (e.g., Logging). In C++, metaclass-like behavior is achieved using **templates, CRTP (Curiously Recurring Template Pattern), and static members**.

---

### **Python: Metaclass Example**
#### **Singleton Metaclass (Restricts a Class to a Single Instance)**
```python
class SingletonMeta(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class Database(metaclass=SingletonMeta):
    def __init__(self, host="localhost"):
        self.host = host

db1 = Database()
db2 = Database("example.com")

print(db1 is db2)  # True: Both refer to the same instance
```

#### **Logging Metaclass (Adds Logging to All Methods)**
```python
class LoggingMeta(type):
    def __new__(mcs, name, bases, attributes):
        for attr_name, attr_value in attributes.items():
            if callable(attr_value) and not attr_name.startswith("__"):
                attributes[attr_name] = LoggingMeta.add_logging(attr_value, name)
        return super().__new__(mcs, name, bases, attributes)

    @staticmethod
    def add_logging(method, class_name):
        def wrapper(*args, **kwargs):
            print(f"Calling {method.__name__} on {class_name}")
            result = method(*args, **kwargs)
            print(f"{method.__name__} returned {result}")
            return result
        return wrapper

class Math(metaclass=LoggingMeta):
    def add(self, x, y):
        return x + y

math = Math()
math.add(2, 3)  
# Output: Calling add on Math
#         add returned 5
```

---

### **C++ Equivalent of Python Metaclasses**
Since C++ doesn’t have metaclasses, similar functionality is implemented using:
- **Singleton Pattern** (Static instance inside a method)
- **Templates & CRTP** (Adding behaviors like logging)

#### **Singleton Pattern in C++**
```cpp
#include <iostream>

class Database {
private:
    static Database* instance;
    std::string host;

    // Private constructor
    Database(std::string h = "localhost") : host(h) {}

public:
    static Database* getInstance(std::string h = "localhost") {
        if (instance == nullptr)
            instance = new Database(h);
        return instance;
    }

    std::string getHost() { return host; }
};

Database* Database::instance = nullptr;

int main() {
    Database* db1 = Database::getInstance();
    Database* db2 = Database::getInstance("example.com");

    std::cout << (db1 == db2) << std::endl;  // Output: 1 (True)
    std::cout << db1->getHost() << std::endl; // Output: localhost
}
```

---

#### **CRTP for Logging (Metaclass-like Behavior)**
```cpp
#include <iostream>

template <typename Derived>
class Logger {
public:
    void log(const std::string& method) {
        std::cout << "Calling " << method << " on " << typeid(Derived).name() << std::endl;
    }
};

class Math : public Logger<Math> {
public:
    int add(int x, int y) {
        log("add");
        return x + y;
    }
};

int main() {
    Math math;
    std::cout << math.add(2, 3) << std::endl;
}
```
**Output:**
```
Calling add on Math
5
```

---

### **Comparison: Python vs C++**
| Feature         | Python (Metaclasses) | C++ Equivalent |
|---------------|----------------|----------------|
| **Singleton** | `__call__` method in metaclass | Static instance in class |
| **Logging**   | `__new__` method modifies class methods | CRTP (Curiously Recurring Template Pattern) |
| **Customization** | Can alter behavior at runtime | Must define at compile-time using templates |

---

### **Summary**
- **Python Metaclasses**: Define how classes behave, useful for enforcing patterns like Singleton and adding functionality like Logging.
- **C++ Equivalent**:
  - **Singleton Pattern**: Uses a static instance to ensure only one object exists.
  - **CRTP (Curiously Recurring Template Pattern)**: Simulates metaclasses by adding behaviors at compile time.

While Python metaclasses allow dynamic class modification, C++ relies on **compile-time mechanisms like templates and static members** for similar functionality.

---

## **Advanced Design Patterns: Explanation & Comparison (Python vs. C++)**

Design patterns provide reusable solutions to common programming problems. Below, we explain three advanced design patterns with their usage and a comparison between **Python** and **C++** implementations.

---

## **1. Singleton Pattern**
### **Concept**
The **Singleton Pattern** ensures that a class has only one instance and provides a global access point to it. This is commonly used in scenarios like database connections, configuration management, and logging.

### **Python Implementation**
Python implements the Singleton pattern using **class variables** or **metaclasses**.

```python
class Singleton:
    """A class implementing the Singleton pattern using a class variable."""
    
    _instance = None  # Class variable to store instance
    
    def __new__(cls, *args, **kwargs):
        """Ensure only one instance is created."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self, value=None):
        """Initialize the singleton instance (only once)."""
        if not hasattr(self, "initialized"):
            self.value = value
            self.initialized = True


# Usage
s1 = Singleton(10)
s2 = Singleton(20)

print(s1 is s2)  # True (both refer to the same instance)
print(s1.value)  # 10
print(s2.value)  # 10 (singleton ensures only one instance)
```

### **C++ Implementation**
C++ implements the Singleton pattern using **static variables** and **private constructors**.

```cpp
#include <iostream>

class Singleton {
private:
    static Singleton* instance;
    int value;
    
    // Private constructor prevents instantiation from outside
    Singleton(int val) : value(val) {}

public:
    static Singleton* getInstance(int val = 0) {
        if (instance == nullptr) {
            instance = new Singleton(val);
        }
        return instance;
    }
    
    int getValue() { return value; }
};

// Initialize static instance pointer
Singleton* Singleton::instance = nullptr;

int main() {
    Singleton* s1 = Singleton::getInstance(10);
    Singleton* s2 = Singleton::getInstance(20);

    std::cout << (s1 == s2) << std::endl;  // Output: 1 (true)
    std::cout << s1->getValue() << std::endl;  // Output: 10
    std::cout << s2->getValue() << std::endl;  // Output: 10

    return 0;
}
```

### **Python vs. C++ Comparison**
| Feature         | Python Singleton | C++ Singleton |
|---------------|----------------|---------------|
| **Instance Storage** | Class variable (`_instance`) | Static pointer (`instance`) |
| **Thread Safety** | Needs explicit handling | Needs explicit handling |
| **Instantiation** | Uses `__new__()` override | Uses private constructor |
| **Garbage Collection** | Automatic | Needs manual deletion (heap allocation) |

---

## **2. Factory Pattern**
### **Concept**
The **Factory Pattern** is used to create objects without specifying their exact class. It is commonly used when object creation logic is complex or when multiple subclasses need to be instantiated dynamically.

### **Python Implementation**
In Python, a factory method can return different subclasses based on input parameters.

```python
class Dog:
    def speak(self):
        return "Woof!"

class Cat:
    def speak(self):
        return "Meow!"

class AnimalFactory:
    """A factory class for creating animals."""
    
    @staticmethod
    def create_animal(animal_type):
        if animal_type == "dog":
            return Dog()
        elif animal_type == "cat":
            return Cat()
        else:
            raise ValueError("Unknown animal type")

# Usage
animal = AnimalFactory.create_animal("dog")
print(animal.speak())  # Woof!
```

### **C++ Implementation**
In C++, we use an abstract base class and dynamic allocation.

```cpp
#include <iostream>
using namespace std;

class Animal {
public:
    virtual void speak() = 0; // Pure virtual function
};

class Dog : public Animal {
public:
    void speak() override { cout << "Woof!" << endl; }
};

class Cat : public Animal {
public:
    void speak() override { cout << "Meow!" << endl; }
};

class AnimalFactory {
public:
    static Animal* createAnimal(string type) {
        if (type == "dog") return new Dog();
        if (type == "cat") return new Cat();
        return nullptr;
    }
};

int main() {
    Animal* animal = AnimalFactory::createAnimal("dog");
    if (animal) animal->speak(); // Woof!
    delete animal; // Manual memory management required

    return 0;
}
```

### **Python vs. C++ Comparison**
| Feature         | Python Factory | C++ Factory |
|---------------|---------------|---------------|
| **Polymorphism** | Dynamic via duck typing | Explicit via inheritance |
| **Memory Management** | Automatic | Manual (`new/delete`) |
| **Flexibility** | Uses dictionary mapping | Uses `switch` or `if-else` |

---

## **3. Observer Pattern**
### **Concept**
The **Observer Pattern** is used when multiple objects (observers) need to be updated whenever a state change occurs in another object (subject). It is widely used in event-driven programming, UI frameworks, and stock market notifications.

### **Python Implementation**
Python uses lists to manage observer subscriptions.

```python
class Subject:
    def __init__(self):
        self._observers = []
    
    def attach(self, observer):
        self._observers.append(observer)
    
    def detach(self, observer):
        self._observers.remove(observer)
    
    def notify(self, data):
        for observer in self._observers:
            observer.update(data)

class Investor:
    def __init__(self, name):
        self.name = name
    
    def update(self, data):
        print(f"{self.name} received stock update: {data}")

# Usage
market = Subject()
investor1 = Investor("Alice")
investor2 = Investor("Bob")

market.attach(investor1)
market.attach(investor2)

market.notify("Stock price is $100")
# Alice received stock update: Stock price is $100
# Bob received stock update: Stock price is $100
```

### **C++ Implementation**
C++ requires explicit observer registration and manual memory management.

```cpp
#include <iostream>
#include <vector>
using namespace std;

class Observer {
public:
    virtual void update(string data) = 0;
};

class Investor : public Observer {
    string name;
public:
    Investor(string n) : name(n) {}
    void update(string data) override {
        cout << name << " received stock update: " << data << endl;
    }
};

class Subject {
    vector<Observer*> observers;
public:
    void attach(Observer* obs) { observers.push_back(obs); }
    void detach(Observer* obs) { observers.erase(remove(observers.begin(), observers.end(), obs), observers.end()); }
    void notify(string data) {
        for (auto obs : observers) obs->update(data);
    }
};

int main() {
    Subject market;
    Investor alice("Alice"), bob("Bob");

    market.attach(&alice);
    market.attach(&bob);

    market.notify("Stock price is $100");

    return 0;
}
```

### **Python vs. C++ Comparison**
| Feature         | Python Observer | C++ Observer |
|---------------|---------------|---------------|
| **Observer Storage** | List | `vector<Observer*>` |
| **Memory Management** | Automatic | Manual (`delete` if dynamic) |
| **Flexibility** | Dynamic with duck typing | Requires explicit interface |

---

| Pattern | Python | C++ |
|---------|--------|------|
| **Singleton** | Uses `__new__()` and class variables | Uses static pointers and private constructors |
| **Factory** | Uses static methods and dynamic type resolution | Uses inheritance and pointers |
| **Observer** | Uses lists for observer storage | Uses vectors and manual memory management |

