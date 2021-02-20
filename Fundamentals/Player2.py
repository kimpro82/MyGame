# generating a player who has location (a,b) and its trace data
class player :

    def __init__(self, name='', location=[0,0], trace=[[0,0]]) :
        self.name = name
        # add validation
        self.location = location
        if not (type(self.location)==list and len(self.location)==2) :
            raise ValueError("The location's shape is not [x, y].")
        # add validation
        self.trace = trace
        if not (type(self.trace)==list and len(self.trace)==1
            and len(self.trace[0])==2) :
            raise ValueError("The trace's shape is not [[x, y]].")
    
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


# generating an instance
p1 = player() 


# Results
print(p1.right())
print(p1.up(3))
print(p1.left(2))
print(p1.trace)


# practice
type([0,0])
type([0,0])==list
len([0,0])

not True
not(True)
not True and False
not(True and False)
