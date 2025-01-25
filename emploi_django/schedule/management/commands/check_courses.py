from django.core.management.base import BaseCommand
from schedule.models import Course

class Command(BaseCommand):
    help = 'Check course data and calculations'

    def handle(self, *args, **options):
        courses = Course.objects.all()
        self.stdout.write(f"Found {courses.count()} courses")
        
        for course in courses:
            self.stdout.write("\n" + "="*50)
            self.stdout.write(f"Course: {course.code} - {course.title}")
            self.stdout.write(f"CM: {course.cm_completed}/{course.cm_hours} = {course.progress_cm():.2f}%")
            self.stdout.write(f"TD: {course.td_completed}/{course.td_hours} = {course.progress_td():.2f}%")
            self.stdout.write(f"TP: {course.tp_completed}/{course.tp_hours} = {course.progress_tp():.2f}%")
            total_planned = course.cm_hours + course.td_hours + course.tp_hours
            total_completed = course.cm_completed + course.td_completed + course.tp_completed
            self.stdout.write(f"Total: {total_completed}/{total_planned} = {course.total_progress():.2f}%")
