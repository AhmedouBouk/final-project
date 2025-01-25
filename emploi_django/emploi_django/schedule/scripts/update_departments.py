import os
import django
import sys

# Add the project directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emploi_django.settings')
django.setup()

from schedule.models import Department, Semester

def update_departments():
    # Remove default department if it exists
    try:
        default_dept = Department.objects.get(code='DEFAULT')
        print(f"Removing default department: {default_dept.name}")
        default_dept.delete()
    except Department.DoesNotExist:
        print("Default department not found")

    # Add MPG department
    mpg_dept, created = Department.objects.get_or_create(
        code='MPG',
        defaults={'name': 'Maintenance et Production de Gaz'}
    )
    
    if created:
        print(f"Created department: {mpg_dept.name}")
        # Create semesters for MPG
        for sem_code in ['S1', 'S2', 'S3', 'S4']:
            semester, _ = Semester.objects.get_or_create(
                code=sem_code,
                department=mpg_dept
            )
            print(f"Created semester {sem_code} for {mpg_dept.name}")
    else:
        print(f"Department already exists: {mpg_dept.name}")

if __name__ == '__main__':
    print("Starting to update departments...")
    update_departments()
    print("Department update completed!")
