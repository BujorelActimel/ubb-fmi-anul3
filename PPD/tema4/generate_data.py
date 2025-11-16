import random
import os

NUM_STUDENTS = 200
NUM_PROJECTS = 10
MIN_GRADES_PER_FILE = 80
MAX_GRADE = 10

def generate_project_files():
    # Create data directory if it doesn't exist
    os.makedirs("data", exist_ok=True)

    for project in range(1, NUM_PROJECTS + 1):
        filename = f"data/proiect{project}.txt"

        # Generate random number of grades (at least MIN_GRADES_PER_FILE)
        num_grades = MIN_GRADES_PER_FILE + random.randint(0, 50)

        # Randomly select students who submitted this project (no duplicates)
        students = random.sample(range(1, NUM_STUDENTS + 1), num_grades)

        # Sort students by ID for easier verification
        students.sort()

        with open(filename, 'w') as file:
            for student_id in students:
                grade = random.randint(1, MAX_GRADE)
                file.write(f"({student_id}, {grade})\n")

        print(f"Generated {filename} with {num_grades} grades")

    print(f"\nData generation complete!")
    print(f"Generated {NUM_PROJECTS} project files with random grades for {NUM_STUDENTS} students.")

if __name__ == "__main__":
    generate_project_files()
