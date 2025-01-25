from django.core.management.base import BaseCommand
from schedule.models import Course, CourseAssignment, TimeSlot
from django.db import transaction

class Command(BaseCommand):
    help = 'Test progress calculations for all courses'

    def add_arguments(self, parser):
        parser.add_argument(
            '--create-test-data',
            action='store_true',
            help='Create test schedule data',
        )

    def handle(self, *args, **options):
        if options['create_test_data']:
            self.create_test_data()
        
        # Test all courses
        courses = Course.objects.all()
        self.stdout.write("\nTesting progress calculations for all courses:")
        self.stdout.write("=" * 50)
        
        for course in courses:
            self.stdout.write(f"\nCourse: {course.code} - {course.title}")
            self.stdout.write("-" * 50)
            
            # Get planned hours from schedule
            planned_cm = course.get_planned_hours('CM')
            planned_td = course.get_planned_hours('TD')
            planned_tp = course.get_planned_hours('TP')
            
            # Update completed hours based on schedule
            course.update_completed_hours()
            
            # Show results
            self.stdout.write(f"CM Hours:")
            self.stdout.write(f"  - Database: {course.cm_hours}")
            self.stdout.write(f"  - Planned in Schedule: {planned_cm}")
            self.stdout.write(f"  - Completed: {course.cm_completed}")
            self.stdout.write(f"  - Progress: {course.progress_cm()}%")
            
            self.stdout.write(f"\nTD Hours:")
            self.stdout.write(f"  - Database: {course.td_hours}")
            self.stdout.write(f"  - Planned in Schedule: {planned_td}")
            self.stdout.write(f"  - Completed: {course.td_completed}")
            self.stdout.write(f"  - Progress: {course.progress_td()}%")
            
            self.stdout.write(f"\nTP Hours:")
            self.stdout.write(f"  - Database: {course.tp_hours}")
            self.stdout.write(f"  - Planned in Schedule: {planned_tp}")
            self.stdout.write(f"  - Completed: {course.tp_completed}")
            self.stdout.write(f"  - Progress: {course.progress_tp()}%")
            
            self.stdout.write(f"\nTotal Progress: {course.total_progress()}%")
    
    @transaction.atomic
    def create_test_data(self):
        """Create test schedule data for demonstration"""
        self.stdout.write("Creating test schedule data...")
        
        # Get first course for testing
        course = Course.objects.first()
        if not course:
            self.stdout.write("No courses found in database")
            return
        
        # Create test assignments if they don't exist
        for type_code in ['CM', 'TD', 'TP']:
            assignment, created = CourseAssignment.objects.get_or_create(
                course=course,
                type=type_code
            )
            
            # Create some test slots
            if created:
                for week in range(1, 4):  # First 3 weeks
                    TimeSlot.objects.create(
                        week=week,
                        day=1,  # Monday
                        period=1,  # First period
                        course_assignment=assignment
                    )
        
        self.stdout.write("Test data created successfully")
