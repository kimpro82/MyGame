# [My Game Fundamentals Groundworks]
- Player2.py (2019.12.15)
- Player.py (2019.03.12) - maybe?


## Player2 (2019.12.15)
Updates : correct use of `__init__`, add validation of variables and use `return` in each method

```python
# generating a player who has location (a,b) and its trace data
class player :

    def __init__(self, name='', location=[0,0]) :
        self.name = name
        # add validation
        self.location = location
            if not (type(self.location)==list and len(self.location)==2) :
                raise ValueError("The location's shape is not [x, y].")
        self.trace = [self.location]
    
    # methods for moving
    def right(self, num=1) :
        self.location = [self.location[0] + num, self.location[1]]
        self.trace.append(self.location)
        return self.location
        # Is there any other way to avoid repeat this common line?
    
    def left(self, num=1) :
        self.location = [self.location[0] - num, self.location[1]]
        self.trace.append(self.location)
        return self.location
    
    def up(self, num=1) :
        self.location = [self.location[0], self.location[1] + num]
        self.trace.append(self.location)
        return self.location
    
    def down(self, num=1) :
        self.location = [self.location[0], self.location[1] - num]
        self.trace.append(self.location)
        return self.location
        
    # Should 'self' be really abused so much like the above?
```

```python
# generating an instance
p1 = player('John', [0,0])
```

```python
p2 = player('John', 1)
```
> ValueError: The location's shape is not [x, y].

```python
# Results
print(p1.right())
print(p1.up(3))
print(p1.left(2))
print(p1.trace)
```
> [1, 0]  
> [1, 3]  
> [-1, 3]  
> [[0, 0], [1, 0], [1, 3], [-1, 3]]  

```python
# practice
type([0,0])
type([0,0])==list
len([0,0])
```
> list  
> True  
> 2  

```python
not True
not(True)
not True and False
not(True and False)
```
> False  
> False  
> False  
> True  


## Player (2019.03.12) - maybe?
A class that traces a player's coordinate

```python
# generating a player who has locatiion (a,b) and its trace data
class player :
    
    name = ''
    # can be named at each instance
    location = [0,0]
    # can be set as a random position (future task)
    trace = [[0,0]]
    # accumulationg as a list of location (a,b)s' trace
    
    def init(self, name, location, trace) : # Why doesn't __init__ work?
    # alternative : def init(self, name='', location=[0,0], trace=[])
        self.name = name
        self.location = location
        self.trace = trace
    
    # methods for moving
    def right(self, num=1) :
        self.location = [self.location[0] + num, self.location[1]]
        self.trace.append(self.location)
        print(self.location)
        # Is there any other way to avoid repeat this common line?
    
    def left(self, num=1) :
        self.location = [self.location[0] - num, self.location[1]]
        self.trace.append(self.location)
        print(self.location)
    
    def up(self, num=1) :
        self.location = [self.location[0], self.location[1] + num]
        self.trace.append(self.location)
        print(self.location)
    
    def down(self, num=1) :
        self.location = [self.location[0], self.location[1] - num]
        self.trace.append(self.location)
        print(self.location)
        
        # Should 'self' be really abused so much like the above?
```

```python
# generating an instance
p1 = player() 

# Results
p1.right()
p1.up(3)
p1.left(2)
print(p1.trace)
```
> [1, 0]  
[1, 3]  
[-1, 3]  
[[0, 0], [1, 0], [1, 3], [-1, 3]]  
