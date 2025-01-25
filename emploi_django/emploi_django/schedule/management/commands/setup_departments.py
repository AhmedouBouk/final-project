from django.core.management.base import BaseCommand
from schedule.models import Department

class Command(BaseCommand):
    help = 'Create initial departments'

    def handle(self, *args, **kwargs):
        # Create departments
        departments = [
            ('IRT', 'Informatique, Réseaux et Télécommunications'),
            ('GM', 'Génie Mécanique'),
        ]
        
        for code, name in departments:
            Department.objects.get_or_create(
                code=code,
                name=name
            )
            self.stdout.write(self.style.SUCCESS(f'Successfully created department {code}'))
