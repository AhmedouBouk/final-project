from django.core.management.base import BaseCommand
from schedule.models import Course

class Command(BaseCommand):
    help = 'Test progress calculations'

    def handle(self, *args, **options):
        # Get a course to test with
        course = Course.objects.first()
        if not course:
            self.stdout.write("No courses found in database")
            return

        # Test different completion scenarios
        test_cases = [
            {'cm': 2, 'td': 2, 'tp': 2},
            {'cm': 0, 'td': 3, 'tp': 4},
            {'cm': 5, 'td': 0, 'tp': 6},
        ]

        for i, test in enumerate(test_cases, 1):
            self.stdout.write(f"\nTest Case {i}:")
            self.stdout.write("-" * 50)
            
            # Update completion values
            course.cm_completed = test['cm']
            course.td_completed = test['td']
            course.tp_completed = test['tp']
            course.save()

            # Calculate and show progress
            self.stdout.write(f"Course: {course.code}")
            self.stdout.write(f"CM: {course.cm_completed}/{course.cm_hours} = {course.progress_cm():.2f}%")
            self.stdout.write(f"TD: {course.td_completed}/{course.td_hours} = {course.progress_td():.2f}%")
            self.stdout.write(f"TP: {course.tp_completed}/{course.tp_hours} = {course.progress_tp():.2f}%")
            self.stdout.write(f"Total: {course.total_progress():.2f}%")
