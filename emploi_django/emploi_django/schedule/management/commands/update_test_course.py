from django.core.management.base import BaseCommand
from schedule.models import Course

class Command(BaseCommand):
    help = 'Update test course with completed hours'

    def handle(self, *args, **options):
        try:
            # Get IRT31 course
            course = Course.objects.get(code='IRT31')
            
            # Update completed hours
            course.cm_completed = 3  # 3 out of 6 hours (50%)
            course.td_completed = 4  # 4 out of 6 hours (66.67%)
            course.tp_completed = 6  # 6 out of 12 hours (50%)
            course.save()
            
            # Show updated progress
            self.stdout.write(self.style.SUCCESS(f"Updated course: {course.code}"))
            self.stdout.write(f"CM Progress: {course.progress_cm():.2f}%")
            self.stdout.write(f"TD Progress: {course.progress_td():.2f}%")
            self.stdout.write(f"TP Progress: {course.progress_tp():.2f}%")
            self.stdout.write(f"Total Progress: {course.total_progress():.2f}%")
            
        except Course.DoesNotExist:
            self.stdout.write(self.style.ERROR("Course IRT31 not found"))
