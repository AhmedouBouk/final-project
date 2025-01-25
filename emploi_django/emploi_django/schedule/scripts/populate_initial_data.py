import os
import django
import sys

# Add the project directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emploi_django.settings')
django.setup()

from schedule.models import Department, Semester

def populate_data():
    # Define departments
    departments_data = [
        {'code': 'IRT', 'name': 'Internet et Réseaux de Télécommunications'},
        {'code': 'GI', 'name': 'Génie Informatique'},
        {'code': 'GE', 'name': 'Génie Électrique'},
        {'code': 'GM', 'name': 'Génie Mécanique'},
        {'code': 'GC', 'name': 'Génie Civil'},
    ]

    # Create departments
    departments = []
    for dept_data in departments_data:
        dept, created = Department.objects.get_or_create(
            code=dept_data['code'],
            defaults={'name': dept_data['name']}
        )
        departments.append(dept)
        if created:
            print(f"Created department: {dept.name}")
        else:
            print(f"Department already exists: {dept.name}")

    # Create semesters for each department
    semester_codes = ['S1', 'S2', 'S3', 'S4']
    
    for dept in departments:
        for sem_code in semester_codes:
            semester, created = Semester.objects.get_or_create(
                code=sem_code,
                department=dept
            )
            if created:
                print(f"Created semester {sem_code} for {dept.name}")
            else:
                print(f"Semester {sem_code} already exists for {dept.name}")

if __name__ == '__main__':
    print("Starting to populate data...")
    populate_data()
    print("Data population completed!")
