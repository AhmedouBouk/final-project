from django.core.management.base import BaseCommand
from schedule.models import Course, Professor, Room, CourseAssignment

class Command(BaseCommand):
    help = 'Populate database with initial data'

    def handle(self, *args, **kwargs):
        # Create Professors
        professors = {
            'Aboubecrine': Professor.objects.create(name='Aboubecrine'),
            'Hafedh': Professor.objects.create(name='Hafedh'),
            'El Aoun': Professor.objects.create(name='El Aoun'),
            'Sass': Professor.objects.create(name='Sass'),
            'Moktar': Professor.objects.create(name='Moktar'),
            'Elhacen': Professor.objects.create(name='Elhacen'),
            'Helmi': Professor.objects.create(name='Helmi'),
        }

        # Create Rooms
        rooms = {
            '104': Room.objects.create(number='104', type='AMPHI'),
            'Labo IRT': Room.objects.create(number='Labo IRT', type='LAB'),
            'Lab Electro': Room.objects.create(number='Lab Electro', type='LAB'),
        }

        # Create Courses with their assignments
        courses_data = [
            {
                'code': 'IRT31',
                'title': 'Développement JEE',
                'credits': 3,
                'cm_hours': 6,
                'td_hours': 6,
                'tp_hours': 12,
                'assignments': {
                    'CM': ('Aboubecrine', '104'),
                    'TD': ('Aboubecrine', '104'),
                    'TP': ('Aboubecrine', '104'),
                }
            },
            {
                'code': 'IRT32',
                'title': 'Intelligence artificielle',
                'credits': 2,
                'cm_hours': 5,
                'td_hours': 5,
                'tp_hours': 6,
                'assignments': {
                    'CM': ('Hafedh', '104'),
                    'TD': ('Hafedh', '104'),
                    'TP': ('Hafedh', '104'),
                }
            },
            {
                'code': 'IRT33',
                'title': 'Théorie des langages et compilation',
                'credits': 2,
                'cm_hours': 5,
                'td_hours': 5,
                'tp_hours': 6,
                'assignments': {
                    'CM': ('Hafedh', '104'),
                    'TD': ('Hafedh', '104'),
                    'TP': ('Hafedh', '104'),
                }
            },
            {
                'code': 'IRT34',
                'title': 'Communications numériques',
                'credits': 2,
                'cm_hours': 5,
                'td_hours': 5,
                'tp_hours': 6,
                'assignments': {
                    'CM': ('El Aoun', '104'),
                    'TD': ('El Aoun', '104'),
                    'TP': ('Moktar/Elhacen', 'Labo IRT'),
                }
            },
            {
                'code': 'IRT35',
                'title': 'Architecture des ordinateurs',
                'credits': 3,
                'cm_hours': 8,
                'td_hours': 8,
                'tp_hours': 8,
                'assignments': {
                    'CM': ('Sass', '104'),
                    'TD': ('Sass', '104'),
                    'TP': ('Sass', 'Lab Electro'),
                }
            },
            {
                'code': 'IRT36',
                'title': 'Réseaux mobilles',
                'credits': 2,
                'cm_hours': 5,
                'td_hours': 5,
                'tp_hours': 6,
                'assignments': {
                    'CM': ('Moktar', '104'),
                    'TD': ('Moktar', '104'),
                    'TP': ('Moktar', '104'),
                }
            },
            {
                'code': 'IRT37',
                'title': 'Réseaux d\'opérateurs',
                'credits': 2,
                'cm_hours': 5,
                'td_hours': 5,
                'tp_hours': 6,
                'assignments': {
                    'CM': ('El Aoun', '104'),
                    'TD': ('El Aoun', '104'),
                    'TP': ('El Aoun', '104'),
                }
            },
            {
                'code': 'IRT38',
                'title': 'IoT',
                'credits': 2,
                'cm_hours': 5,
                'td_hours': 5,
                'tp_hours': 6,
                'assignments': {
                    'CM': ('Elhacen', '104'),
                    'TD': ('Elhacen', '104'),
                    'TP': ('Helmi', '104'),
                }
            },
            {
                'code': 'PIE',
                'title': 'Projet indusriel en Entreprise (PIE)',
                'credits': 2,
                'cm_hours': 0,
                'td_hours': 24,
                'tp_hours': 48,
                'assignments': {
                    'TD': ('Enseignants du dpt.', '104'),
                    'TP': ('Enseignants du dpt.', '104'),
                }
            },
        ]

        for course_data in courses_data:
            course = Course.objects.create(
                code=course_data['code'],
                title=course_data['title'],
                credits=course_data['credits'],
                cm_hours=course_data['cm_hours'],
                td_hours=course_data['td_hours'],
                tp_hours=course_data['tp_hours']
            )

            # Create assignments
            for type_key, (prof_name, room_number) in course_data['assignments'].items():
                # Handle special case for multiple professors
                if '/' in prof_name:
                    prof_name = prof_name.split('/')[0]  # Take the first professor for now
                
                # Handle special case for "Enseignants du dpt."
                if prof_name == 'Enseignants du dpt.':
                    professor = Professor.objects.create(name=prof_name)
                else:
                    professor = professors[prof_name]
                
                room = rooms[room_number]
                
                CourseAssignment.objects.create(
                    course=course,
                    professor=professor,
                    room=room,
                    type=type_key
                )

        self.stdout.write(self.style.SUCCESS('Successfully populated database'))
