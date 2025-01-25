from django.core.management.base import BaseCommand
from schedule.models import Department, Course, Professor, Room, CourseAssignment, TimeSlot

class Command(BaseCommand):
    help = 'Test department functionality by creating test data'

    def handle(self, *args, **kwargs):
        # Create all departments
        departments = {
            'IRT': 'Informatique, Réseaux et Télécommunications',
            'GM': 'Génie Mécanique',
            'GE': 'Génie Électrique',
            'SID': 'Science de l\'Ingénieur et Développement',
            'MPG': 'Mathématiques, Physique et Génie',
            'GC': 'Génie Civil'
        }
        
        created_departments = {}
        for code, name in departments.items():
            dept, _ = Department.objects.get_or_create(
                code=code,
                defaults={'name': name}
            )
            created_departments[code] = dept
        
        # Define courses for each department
        department_courses = {
            'IRT': [
                {
                    'code': 'IRT11',
                    'title': 'Introduction à la Programmation',
                    'credits': 3,
                    'cm_hours': 21,
                    'td_hours': 10,
                    'tp_hours': 10
                },
                {
                    'code': 'IRT12',
                    'title': 'Réseaux Informatiques',
                    'credits': 4,
                    'cm_hours': 28,
                    'td_hours': 14,
                    'tp_hours': 14
                }
            ],
            'GM': [
                {
                    'code': 'GM11',
                    'title': 'Mécanique des Fluides',
                    'credits': 4,
                    'cm_hours': 28,
                    'td_hours': 14,
                    'tp_hours': 14
                },
                {
                    'code': 'GM12',
                    'title': 'Résistance des Matériaux',
                    'credits': 3,
                    'cm_hours': 21,
                    'td_hours': 10,
                    'tp_hours': 10
                }
            ],
            'GE': [
                {
                    'code': 'GE11',
                    'title': 'Circuits Électriques',
                    'credits': 4,
                    'cm_hours': 28,
                    'td_hours': 14,
                    'tp_hours': 14
                },
                {
                    'code': 'GE12',
                    'title': 'Électronique Numérique',
                    'credits': 3,
                    'cm_hours': 21,
                    'td_hours': 10,
                    'tp_hours': 10
                }
            ],
            'SID': [
                {
                    'code': 'SID11',
                    'title': 'Génie Logiciel',
                    'credits': 4,
                    'cm_hours': 28,
                    'td_hours': 14,
                    'tp_hours': 14
                },
                {
                    'code': 'SID12',
                    'title': 'Base de Données Avancées',
                    'credits': 3,
                    'cm_hours': 21,
                    'td_hours': 10,
                    'tp_hours': 10
                }
            ],
            'MPG': [
                {
                    'code': 'MPG11',
                    'title': 'Analyse Numérique',
                    'credits': 4,
                    'cm_hours': 28,
                    'td_hours': 14,
                    'tp_hours': 14
                },
                {
                    'code': 'MPG12',
                    'title': 'Physique Quantique',
                    'credits': 3,
                    'cm_hours': 21,
                    'td_hours': 10,
                    'tp_hours': 10
                }
            ],
            'GC': [
                {
                    'code': 'GC11',
                    'title': 'Structures en Béton',
                    'credits': 4,
                    'cm_hours': 28,
                    'td_hours': 14,
                    'tp_hours': 14
                },
                {
                    'code': 'GC12',
                    'title': 'Mécanique des Sols',
                    'credits': 3,
                    'cm_hours': 21,
                    'td_hours': 10,
                    'tp_hours': 10
                }
            ]
        }
        
        # Create professors
        professors = [
            'Dr. Ahmed',
            'Dr. Mohamed',
            'Dr. Ali',
            'Dr. Hassan',
            'Dr. Omar',
            'Dr. Youssef'
        ]
        created_professors = []
        for name in professors:
            prof, _ = Professor.objects.get_or_create(name=name)
            created_professors.append(prof)
        
        # Create rooms
        rooms = {
            'CM': ['A101', 'A102', 'A103'],
            'TD': ['B201', 'B202', 'B203'],
            'TP': ['LAB1', 'LAB2', 'LAB3']
        }
        
        created_rooms = {}
        for room_type, numbers in rooms.items():
            created_rooms[room_type] = []
            for number in numbers:
                room, _ = Room.objects.get_or_create(number=number)
                created_rooms[room_type].append(room)
        
        # Create courses and assignments for each department
        for dept_code, courses in department_courses.items():
            department = created_departments[dept_code]
            
            for course_data in courses:
                course, created = Course.objects.get_or_create(
                    code=course_data['code'],
                    department=department,
                    defaults={
                        'title': course_data['title'],
                        'credits': course_data['credits'],
                        'cm_hours': course_data['cm_hours'],
                        'td_hours': course_data['td_hours'],
                        'tp_hours': course_data['tp_hours']
                    }
                )
                
                # Assign random professors and rooms for each type
                for course_type, rooms in created_rooms.items():
                    prof = created_professors[hash(course.code + course_type) % len(created_professors)]
                    room = rooms[hash(course.code + course_type) % len(rooms)]
                    
                    CourseAssignment.objects.get_or_create(
                        course=course,
                        professor=prof,
                        type=course_type,
                        defaults={'room': room}
                    )
        
        self.stdout.write(self.style.SUCCESS('Successfully created test data for all departments'))
