from django.core.management.base import BaseCommand
from schedule.models import Course

class Command(BaseCommand):
    help = 'Test IRT32 course progress calculations'

    def handle(self, *args, **options):
        try:
            # Get IRT32 course
            course = Course.objects.get(code='IRT32')
            
            # Show initial state
            self.stdout.write("\nInitial state:")
            self.stdout.write("-" * 50)
            self.stdout.write(f"Course: {course.code} - {course.title}")
            self.stdout.write(f"CM: {course.cm_completed}/{course.cm_hours} = {course.progress_cm():.2f}%")
            self.stdout.write(f"TD: {course.td_completed}/{course.td_hours} = {course.progress_td():.2f}%")
            self.stdout.write(f"TP: {course.tp_completed}/{course.tp_hours} = {course.progress_tp():.2f}%")
            self.stdout.write(f"Total: {course.total_progress():.2f}%")
            
            # Test different completion scenarios
            test_cases = [
                {
                    'name': 'Partial completion',
                    'cm': 2,  # 2/5 = 40%
                    'td': 3,  # 3/5 = 60%
                    'tp': 4,  # 4/6 = 66.67%
                },
                {
                    'name': 'Full CM, partial others',
                    'cm': 5,  # 5/5 = 100%
                    'td': 2,  # 2/5 = 40%
                    'tp': 3,  # 3/6 = 50%
                },
                {
                    'name': 'Mixed completion',
                    'cm': 3,  # 3/5 = 60%
                    'td': 5,  # 5/5 = 100%
                    'tp': 2,  # 2/6 = 33.33%
                }
            ]

            for test in test_cases:
                self.stdout.write(f"\n{test['name']}:")
                self.stdout.write("-" * 50)
                
                # Update completion values
                course.cm_completed = test['cm']
                course.td_completed = test['td']
                course.tp_completed = test['tp']
                course.save()

                # Calculate and show progress
                self.stdout.write(f"CM: {course.cm_completed}/{course.cm_hours} = {course.progress_cm():.2f}%")
                self.stdout.write(f"TD: {course.td_completed}/{course.td_hours} = {course.progress_td():.2f}%")
                self.stdout.write(f"TP: {course.tp_completed}/{course.tp_hours} = {course.progress_tp():.2f}%")
                total_completed = course.cm_completed + course.td_completed + course.tp_completed
                total_planned = course.cm_hours + course.td_hours + course.tp_hours
                self.stdout.write(f"Total completed: {total_completed}/{total_planned}")
                self.stdout.write(f"Total progress: {course.total_progress():.2f}%")
            
        except Course.DoesNotExist:
            self.stdout.write(self.style.ERROR("Course IRT32 not found"))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"Error: {str(e)}"))
