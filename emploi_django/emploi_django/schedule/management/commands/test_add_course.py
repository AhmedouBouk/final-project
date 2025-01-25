from django.core.management.base import BaseCommand
from django.test import Client
from django.urls import reverse
import json
from schedule.models import Course, Professor, Room, CourseAssignment

class Command(BaseCommand):
    help = 'Test adding a new course through the API'

    def handle(self, *args, **options):
        # First, clean up any existing test courses
        Course.objects.filter(code__startswith='TEST').delete()
        self.stdout.write("Cleaned up existing test courses")

        client = Client()

        # Test data for a new course
        test_courses = [
            {
                'code': 'TEST01',
                'title': 'Test Course 1',
                'credits': '3',
                'cm_hours': '10',
                'td_hours': '8',
                'tp_hours': '12',
                'cm_professor': 'Dr. Test',
                'td_professor': 'Dr. Test',
                'tp_professor': 'Dr. Test',
                'cm_room': 'R101',
                'tp_room': 'LAB1'
            },
            {
                'code': 'TEST02',
                'title': 'Test Course 2',
                'credits': '4',
                'cm_hours': '15',
                'td_hours': '10',
                'tp_hours': '15',
                'cm_professor': 'Prof. Example',
                'tp_professor': 'Dr. Lab',
                'cm_room': 'R102',
                'tp_room': 'LAB2'
            }
        ]

        self.stdout.write(self.style.SUCCESS('Starting add course tests...'))

        for course_data in test_courses:
            self.stdout.write(f"\nTesting course: {course_data['code']}")
            self.stdout.write('-' * 50)

            # Try to add the course
            response = client.post('/add_course/', course_data)

            # Check response
            if response.status_code == 200:
                data = json.loads(response.content)
                if data.get('status') == 'success':
                    self.stdout.write(self.style.SUCCESS(f"✓ Successfully added course {course_data['code']}"))
                    self.stdout.write("Course details:")
                    for key, value in data['course'].items():
                        self.stdout.write(f"  - {key}: {value}")
                else:
                    self.stdout.write(self.style.ERROR(f"✗ Failed to add course: {data.get('error')}"))
            else:
                self.stdout.write(self.style.ERROR(f"✗ Request failed with status code: {response.status_code}"))
                self.stdout.write(f"Response: {response.content}")

        # Verify the courses were added
        self.stdout.write("\nVerifying added courses...")
        self.stdout.write('-' * 50)
        
        for course_data in test_courses:
            try:
                course = Course.objects.get(code=course_data['code'])
                self.stdout.write(self.style.SUCCESS(f"✓ Found course {course.code} in database"))
                self.stdout.write(f"  - Title: {course.title}")
                self.stdout.write(f"  - Credits: {course.credits}")
                self.stdout.write(f"  - CM Hours: {course.cm_hours}")
                self.stdout.write(f"  - TD Hours: {course.td_hours}")
                self.stdout.write(f"  - TP Hours: {course.tp_hours}")
                
                # Check professors
                for assignment in course.courseassignment_set.all():
                    self.stdout.write(f"  - {assignment.type} Professor: {assignment.professor.name}")
                    if assignment.room:
                        self.stdout.write(f"  - {assignment.type} Room: {assignment.room.number}")
            except Course.DoesNotExist:
                self.stdout.write(self.style.ERROR(f"✗ Course {course_data['code']} not found in database"))
