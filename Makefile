CC = g++
CFLAGS = -std=c++11 -Wall -g
EXEC_NAME = Exercice4_Huber_Berdyev
INCLUDES =
LIBS =
OBJ_FILES = Exercice4_Huber_Berdyev.o

all : $(EXEC_NAME)

clean :
	rm -f $(EXEC_NAME) $(OBJ_FILES) *.out

$(EXEC_NAME) : $(OBJ_FILES)
	$(CC) -o $(EXEC_NAME) $(OBJ_FILES) $(LIBS)

%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $<
