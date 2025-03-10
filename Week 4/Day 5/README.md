[OOPS.py](#oopspy)
- [OOPS.py](#oopspy)
  - [**1. Method Overriding in Python vs. C++**](#1-method-overriding-in-python-vs-c)
    - [**Python:**](#python)
    - [**C++:**](#c)
  - [**2. Method Overloading in Python vs. C++**](#2-method-overloading-in-python-vs-c)
    - [**Python:**](#python-1)
    - [**C++:**](#c-1)
  - [**3. Limitations of Overriding and Overloading in Python**](#3-limitations-of-overriding-and-overloading-in-python)
    - [**Limitations of Overriding in Python**](#limitations-of-overriding-in-python)
    - [**Limitations of Overloading in Python**](#limitations-of-overloading-in-python)
  - [**Conclusion**](#conclusion)
- [Shallow  vs Deep copy](#shallow--vs-deep-copy)
    - [**Shallow Copy vs. Deep Copy in Python (Comparison with C++)**](#shallow-copy-vs-deep-copy-in-python-comparison-with-c)
  - [**1. Shallow Copy vs. Deep Copy in Python**](#1-shallow-copy-vs-deep-copy-in-python)
    - [**Shallow Copy (`copy.copy()`)**](#shallow-copy-copycopy)
    - [**Deep Copy (`copy.deepcopy()`)**](#deep-copy-copydeepcopy)
    - [**Python Example Breakdown**](#python-example-breakdown)
      - [**Classes:**](#classes)
      - [**Original Object Creation**](#original-object-creation)
      - [**Creating Copies**](#creating-copies)
      - [**Checking Object IDs**](#checking-object-ids)
      - [**Checking Address IDs**](#checking-address-ids)
      - [**Modifying the Original Object**](#modifying-the-original-object)
      - [**Results After Modification**](#results-after-modification)
  - [**2. Shallow Copy vs. Deep Copy in C++**](#2-shallow-copy-vs-deep-copy-in-c)
    - [**Shallow Copy in C++**](#shallow-copy-in-c)
    - [**Deep Copy in C++**](#deep-copy-in-c)
  - [**3. Comparison Table: Python vs. C++**](#3-comparison-table-python-vs-c)
  - [**4. Limitations of Shallow Copy and Deep Copy in Python**](#4-limitations-of-shallow-copy-and-deep-copy-in-python)
    - [**Limitations of Shallow Copy**](#limitations-of-shallow-copy)
    - [**Limitations of Deep Copy**](#limitations-of-deep-copy)
- [**File Operations in Python and C++**](#file-operations-in-python-and-c)
  - [**1. Creating a File**](#1-creating-a-file)
  - [**2. Writing to a File**](#2-writing-to-a-file)
  - [**3. Reading from a File**](#3-reading-from-a-file)
  - [**4. Appending to a File**](#4-appending-to-a-file)
  - [**5. Deleting a File**](#5-deleting-a-file)
  - [**6. Checking If a File Exists**](#6-checking-if-a-file-exists)
  - [**7. Getting the Current Working Directory**](#7-getting-the-current-working-directory)
  - [**8. Listing All Files in a Directory**](#8-listing-all-files-in-a-directory)
  - [**9. Getting the Size of a File**](#9-getting-the-size-of-a-file)
  - [**10. Getting the Last Modified Time of a File**](#10-getting-the-last-modified-time-of-a-file)
  - [**11. Getting File Name, Extension, and Path**](#11-getting-file-name-extension-and-path)

# OOPS.py

## **1. Method Overriding in Python vs. C++**
### **Python:**
- **Method overriding** occurs when a child class defines a method with the same name as a method in its parent class.
- When an overridden method is called on an object of the child class, Python executes the child class’s method instead of the parent class’s.

**Example in Python**
```python
class Animal:- 
    def speak(self):
        print("Animal is speaking")

class Dog(Animal):
    def speak(self):
        print("Dog is barking")  # Overrides the parent class's speak() method

dog = Dog()
dog.speak()  # Output: Dog is barking
```
- Here, `Dog.speak()` overrides `Animal.speak()`.

### **C++:**
- C++ supports method overriding using **virtual functions**.
- The overridden method must have the **same function signature** as the parent class.
- We use `virtual` in the base class to ensure polymorphism.

**Example in C++**
```cpp
#include <iostream>
using namespace std;

class Animal {
public:
    virtual void speak() { // Virtual function allows method overriding
        cout << "Animal is speaking" << endl;
    }
};

class Dog : public Animal {
public:
    void speak() override { // Overriding speak() in Dog class
        cout << "Dog is barking" << endl;
    }
};

int main() {
    Animal* animal = new Dog();
    animal->speak(); // Output: Dog is barking (because of overriding)
    delete animal;
    return 0;
}
```
**Key Differences in Overriding**
| Feature      | Python | C++ |
|-------------|--------|-----|
| Virtual Functions Required | No | Yes (`virtual` keyword needed) |
| Type Checking | Dynamic | Static (Compile-time) |
| Function Signature | Can change parameters | Must be exactly the same |
| Use of Pointers | Not needed | Needed for polymorphism (`Animal* a = new Dog();`) |

---

## **2. Method Overloading in Python vs. C++**
### **Python:**
- **Python does NOT support method overloading in the same class.** 
- If you define multiple methods with the same name but different parameters, the last method definition overrides the previous ones.

**Example in Python**
```python
class Dog(Animal):
    def speak(self):
        print(f"Dog {self.name} is barking")
    
    def speak(self, age):
        print(f"Dog {self.name} is barking and {age} years old coming from Method Overloading")

dog = Dog("Buddy")
dog.speak(10)  # Works
dog.speak()    # ERROR! Python does not support method overloading.
```
**Why does this fail?**
- The second `speak()` method overrides the first one.
- Only the last defined method exists in Python.

**Alternative: Using Default Arguments**
```python
class Dog(Animal):
    def speak(self, age=None):
        if age:
            print(f"Dog {self.name} is barking and {age} years old")
        else:
            print(f"Dog {self.name} is barking")

dog = Dog("Buddy")
dog.speak()    # Works
dog.speak(10)  # Works
```
- Python **achieves overloading-like behavior** using **default arguments** and `*args` or `**kwargs`.

### **C++:**
- C++ **fully supports method overloading**.
- The function name can be the same as long as the **parameter list differs** (by type or number of arguments).

**Example in C++**
```cpp
#include <iostream>
using namespace std;

class Dog {
public:
    void speak() {
        cout << "Dog is barking" << endl;
    }
    
    void speak(int age) {
        cout << "Dog is barking and " << age << " years old" << endl;
    }
};

int main() {
    Dog d;
    d.speak();       // Output: Dog is barking
    d.speak(10);     // Output: Dog is barking and 10 years old
    return 0;
}
```
**Key Differences in Overloading**
| Feature      | Python | C++ |
|-------------|--------|-----|
| Multiple Functions with Same Name | Not Allowed | Allowed |
| Function Signature Can Differ | No | Yes |
| Overloading Based on Type | No | Yes |
| Achieved Using | Default Arguments / `*args` | Function Overloading |

---

## **3. Limitations of Overriding and Overloading in Python**
### **Limitations of Overriding in Python**
1. **No Compile-Time Type Checking**: Unlike C++, Python does not check function signatures at compile time.
2. **Accidental Overriding**: If a method in a subclass has the same name as a parent class method but with a different purpose, it can lead to unintended behavior.

### **Limitations of Overloading in Python**
1. **Not Natively Supported**: Python does not allow true method overloading in the same class.
2. **Last Method Definition Wins**: If multiple methods have the same name, only the last one is stored.
3. **Can’t Overload Based on Data Type**: Unlike C++, Python does not differentiate functions based on parameter types.
4. **Achieved with `*args` and `**kwargs`**: Python developers often use flexible function parameters instead of overloading.

---

## **Conclusion**
| Feature      | Python | C++ |
|-------------|--------|-----|
| **Method Overriding** | Supported (No need for `virtual`) | Supported (Requires `virtual`) |
| **Method Overloading** | Not Supported | Fully Supported |
| **Compile-time Type Checking** | No | Yes |
| **Multiple Methods with Same Name in a Class** | No (last one wins) | Yes (based on parameters) |

- **Python supports overriding but not true method overloading.**  
- **C++ supports both overriding and overloading properly.**  
- Python developers use **default arguments, `*args`, and `**kwargs`** to mimic overloading.  
- In C++, overloading is done through **function signatures** (different parameter types or counts).

---

# Shallow  vs Deep copy

### **Shallow Copy vs. Deep Copy in Python (Comparison with C++)**

Your code demonstrates **shallow copy and deep copy** concepts using Python’s `copy` module. Below is a detailed explanation with a comparison to C++.

---

## **1. Shallow Copy vs. Deep Copy in Python**
### **Shallow Copy (`copy.copy()`)**
- A **shallow copy** creates a **new object** but **copies references** to nested objects instead of duplicating them.
- Changes made to **mutable objects (e.g., lists, dictionaries, custom objects inside the copied object)** are reflected in the original object.

### **Deep Copy (`copy.deepcopy()`)**
- A **deep copy** creates a **completely independent object**, including **all nested objects**.
- Any changes made to the original object **do not affect** the deep copy.

---

### **Python Example Breakdown**
#### **Classes:**
```python
class Person:
    def __init__(self, name, address):
        self.name = name
        self.address = address

class Address:
    def __init__(self, city, country):
        self.city = city
        self.country = country
```
- `Person` has a reference to an `Address` object.
- `Address` contains `city` and `country`.

#### **Original Object Creation**
```python
address = Address("New York", "USA")
person = Person("John", address)
```
- `person` refers to an `Address` object.

#### **Creating Copies**
```python
shallow_person = copy.copy(person)   # Shallow Copy
deep_person = copy.deepcopy(person)  # Deep Copy
```
- `shallow_person` has a **new Person object** but the **same Address reference**.
- `deep_person` has a completely **new Address object** as well.

#### **Checking Object IDs**
```python
print(id(person))            # ID of the original person
print(id(shallow_person))    # ID of the shallow copy (different)
print(id(deep_person))       # ID of the deep copy (different)
```
- `person`, `shallow_person`, and `deep_person` have different memory addresses.

#### **Checking Address IDs**
```python
print(id(person.address))         # ID of the original address
print(id(shallow_person.address)) # ID of the shallow copy's address (same as original)
print(id(deep_person.address))    # ID of the deep copy's address (different)
```
- `shallow_person.address` is the **same object** as `person.address` (shallow copy).
- `deep_person.address` is a **new object** (deep copy).

#### **Modifying the Original Object**
```python
person.address.city = "Boston"
```
- The **original address is changed**.

#### **Results After Modification**
```python
print(person)          # Address city = Boston
print(shallow_person)  # Address city = Boston (because it shares the same reference)
print(deep_person)     # Address city = New York (remains unchanged)
```
- The shallow copy reflects the change because it **shares the same address reference**.
- The deep copy remains **unchanged** because it has its **own copy** of `Address`.

---

## **2. Shallow Copy vs. Deep Copy in C++**
### **Shallow Copy in C++**
- In C++, a **default copy constructor** performs a **shallow copy** (copies memory addresses, not the actual objects).
- If one object is modified, it affects the copied object too.

**Example in C++**
```cpp
#include <iostream>
using namespace std;

class Address {
public:
    string city, country;
    Address(string c, string cn) : city(c), country(cn) {}
};

class Person {
public:
    string name;
    Address* address;  // Pointer (shallow copy issue)
    
    Person(string n, Address* addr) : name(n), address(addr) {}
    
    void display() {
        cout << "Person: " << name << ", Address: " << address->city << ", " << address->country << endl;
    }
};

int main() {
    Address* addr = new Address("New York", "USA");
    Person p1("John", addr);

    Person p2 = p1;  // Shallow Copy (Copies address pointer)

    cout << "Before modification:\n";
    p1.display();
    p2.display();

    p1.address->city = "Boston";  // Modifying original object

    cout << "After modification:\n";
    p1.display();  // Boston
    p2.display();  // Boston (same address reference)

    return 0;
}
```
- Since `p2` shares the same `Address` object, modifying `p1` affects `p2` too.

---

### **Deep Copy in C++**
- We manually implement a deep copy by allocating a **new memory block** for the nested object.

**Example in C++**
```cpp
class Person {
public:
    string name;
    Address* address;

    Person(string n, Address* addr) : name(n), address(new Address(addr->city, addr->country)) {}

    ~Person() { delete address; }  // Destructor to prevent memory leaks

    void display() {
        cout << "Person: " << name << ", Address: " << address->city << ", " << address->country << endl;
    }
};
```
- `address` is **dynamically allocated** in the constructor, so each object has its **own copy**.
- This prevents changes in one object from affecting another.

---

## **3. Comparison Table: Python vs. C++**
| Feature | Python Shallow Copy | Python Deep Copy | C++ Shallow Copy | C++ Deep Copy |
|---------|------------------|------------------|------------------|------------------|
| **Creates a new object** | ✅ | ✅ | ✅ | ✅ |
| **Copies nested object references** | ✅ | ❌ | ✅ | ❌ |
| **Nested objects are shared** | ✅ | ❌ | ✅ | ❌ |
| **Independent modifications possible** | ❌ | ✅ | ❌ | ✅ |
| **Requires explicit implementation** | No | No | No | Yes (copy constructor) |

---

## **4. Limitations of Shallow Copy and Deep Copy in Python**
### **Limitations of Shallow Copy**
1. **Nested Objects Are Shared**: If an object contains mutable objects (lists, dictionaries, other objects), the shallow copy will still reference the original ones.
2. **Unintended Side Effects**: Changes in one copy affect the other, leading to unexpected bugs.

### **Limitations of Deep Copy**
1. **Performance Overhead**: Deep copying creates entirely new objects, consuming more memory.
2. **Not Always Necessary**: If objects are immutable (like tuples or strings), a deep copy is redundant.
3. **Circular References Issue**: If an object contains circular references (`a → b → a`), `copy.deepcopy()` needs `__deepcopy__()` to handle it.

---

**Conclusion**

| Aspect | Python Shallow Copy | Python Deep Copy | C++ Shallow Copy | C++ Deep Copy |
|--------|----------------|----------------|----------------|----------------|
| **Copies Object** | ✅ | ✅ | ✅ | ✅ |
| **Copies Nested Objects** | ❌ (references) | ✅ (new objects) | ❌ (pointers) | ✅ (new allocations) |
| **Changes Affect Original?** | ✅ | ❌ | ✅ | ❌ |
| **Memory Efficient?** | ✅ | ❌ (extra memory) | ✅ | ❌ (extra allocations) |
| **Explicit Handling Required?** | No | No | No | Yes (custom copy constructor) |

- **Python's `copy.copy()` behaves like C++'s default copy constructor (shallow copy).**
- **Python's `copy.deepcopy()` mimics manually implemented deep copying in C++.**
- **In C++, deep copy must be explicitly implemented to avoid pointer-related issues.**

---

# **File Operations in Python and C++**

File operations allow us to create, read, write, append, and delete files. Below, we will go through various file operations in **Python** and **C++**, explaining each step with examples.

---

## **1. Creating a File**
We can create a file using **Python's `open()` function** or **C++'s `ofstream` class**.

  
```python
filePath = "test.txt"

def create_file():
    with open(filePath, "w") as file:  # "w" mode creates a new file or overwrites an existing file
        file.write("Hello, World!")    # Write some text into the file

create_file()
```

  
```cpp
#include <iostream>
#include <fstream>

void create_file() {
    std::ofstream file("test.txt"); // Create a file
    file << "Hello, World!";        // Write some text
    file.close();                   // Close the file
}

int main() {
    create_file();
    return 0;
}
```

---

## **2. Writing to a File**
We can write data to a file using **"w" mode** (overwrite) in Python and **ofstream** in C++.

  
```python
def write_to_file():
    with open(filePath, "w") as file:  # Overwrite if the file exists
        file.write("This is a new line.")

write_to_file()
```

  
```cpp
void write_to_file() {
    std::ofstream file("test.txt");  // Opens file and overwrites existing content
    file << "This is a new line.";
    file.close();
}
```

---

## **3. Reading from a File**
To read a file, we use **"r" mode** in Python and **ifstream** in C++.

  
```python
def read_from_file():
    with open(filePath, "r") as file:  # Open file in read mode
        print(file.read())             # Read and print contents

read_from_file()
```

  
```cpp
void read_from_file() {
    std::ifstream file("test.txt"); // Open file in read mode
    std::string content;
    if (file) {
        while (getline(file, content)) { // Read line by line
            std::cout << content << std::endl;
        }
    }
    file.close();
}
```

---

## **4. Appending to a File**
Appending allows us to add content to the existing file without overwriting it.

  
```python
def append_to_file():
    with open(filePath, "a") as file:  # "a" mode appends content
        file.write("\nThis is an appended line.")

append_to_file()
```

  
```cpp
void append_to_file() {
    std::ofstream file("test.txt", std::ios::app); // Open file in append mode
    file << "\nThis is an appended line.";
    file.close();
}
```

---

## **5. Deleting a File**
To delete a file, we use **`os.remove()`** in Python and **`remove()`** in C++.

  
```python
import os

def delete_file():
    if os.path.exists(filePath):  # Check if file exists before deleting
        os.remove(filePath)
        print("File deleted.")
    else:
        print("File does not exist.")

delete_file()
```

  
```cpp
#include <cstdio>  // Needed for remove() function

void delete_file() {
    if (remove("test.txt") == 0) {
        std::cout << "File deleted successfully.\n";
    } else {
        std::cout << "File does not exist.\n";
    }
}
```

---

## **6. Checking If a File Exists**
Before performing operations, it's good practice to check if a file exists.

  
```python
def check_if_file_exists():
    if os.path.exists(filePath):
        print("File exists")
    else:
        print("File does not exist")

check_if_file_exists()
```

  
```cpp
#include <filesystem>  // Required for checking file existence

void check_if_file_exists() {
    if (std::filesystem::exists("test.txt")) {
        std::cout << "File exists.\n";
    } else {
        std::cout << "File does not exist.\n";
    }
}
```

---

## **7. Getting the Current Working Directory**
We can retrieve the current directory where our script is running.

  
```python
def get_current_working_directory():
    print(os.getcwd())

get_current_working_directory()
```

  
```cpp
#include <iostream>
#include <filesystem>

void get_current_working_directory() {
    std::cout << "Current Directory: " << std::filesystem::current_path() << std::endl;
}
```

---

## **8. Listing All Files in a Directory**
Lists all files in the current directory.

  
```python
def list_files_in_directory():
    print(os.listdir())  # Prints list of files and folders

list_files_in_directory()
```

  
```cpp
#include <filesystem>

void list_files_in_directory() {
    for (const auto &entry : std::filesystem::directory_iterator(".")) {
        std::cout << entry.path().filename() << std::endl;
    }
}
```

---

## **9. Getting the Size of a File**
We can get a file’s size using `os.path.getsize()` in Python and `std::filesystem::file_size()` in C++.

  
```python
def get_size_of_file():
    print(os.path.getsize(filePath), "bytes")

get_size_of_file()
```

  
```cpp
void get_size_of_file() {
    std::cout << "Size: " << std::filesystem::file_size("test.txt") << " bytes\n";
}
```

---

## **10. Getting the Last Modified Time of a File**
Retrieves the last modified timestamp.

  
```python
def get_last_modified_time_of_file():
    print(os.path.getmtime(filePath))

get_last_modified_time_of_file()
```

  
```cpp
#include <chrono>

void get_last_modified_time_of_file() {
    auto ftime = std::filesystem::last_write_time("test.txt");
    std::cout << "Last modified time: " << ftime.time_since_epoch().count() << std::endl;
}
```

---

## **11. Getting File Name, Extension, and Path**
We can extract file details like name, extension, and directory.

  
```python
def get_file_name():
    print(os.path.basename(filePath))  # File name

def get_file_extension():
    print(os.path.splitext(filePath)[1])  # File extension

def get_file_directory():
    print(os.path.dirname(filePath))  # File directory

get_file_name()
get_file_extension()
get_file_directory()
```

  
```cpp
void get_file_name() {
    std::cout << "File Name: " << std::filesystem::path("test.txt").filename() << std::endl;
}

void get_file_extension() {
    std::cout << "File Extension: " << std::filesystem::path("test.txt").extension() << std::endl;
}

void get_file_directory() {
    std::cout << "File Directory: " << std::filesystem::path("test.txt").parent_path() << std::endl;
}
```

---
