import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emploi_django.settings')
django.setup()

from schedule.models import Course, Professor, Room, CourseAssignment

# Create Rooms
room_104 = Room.objects.create(number='104', type='CM/TD/TP')

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

# Create Courses with their assignments
courses_data = [
    {
        'code': 'IRT31',
        'title': 'Développement JEE',
        'credits': 3,
        'cm_hours': 6,
        'td_hours': 6,
        'tp_hours': 12,
        'professors': {
            'CM': 'Aboubecrine',
            'TD': 'Aboubecrine',
            'TP': 'Aboubecrine'
        }
    },
    {
        'code': 'IRT32',
        'title': 'Intelligence artificielle',
        'credits': 2,
        'cm_hours': 5,
        'td_hours': 5,
        'tp_hours': 6,
        'professors': {
            'CM': 'Hafedh',
            'TD': 'Hafedh',
            'TP': 'Hafedh'
        }
    },
    {
        'code': 'IRT33',
        'title': 'Théorie des langages et compilation',
        'credits': 2,
        'cm_hours': 5,
        'td_hours': 5,
        'tp_hours': 6,
        'professors': {
            'CM': 'Hafedh',
            'TD': 'Hafedh',
            'TP': 'Hafedh'
        }
    },
    {
        'code': 'IRT34',
        'title': 'Communications numériques',
        'credits': 2,
        'cm_hours': 5,
        'td_hours': 5,
        'tp_hours': 6,
        'professors': {
            'CM': 'El Aoun',
            'TD': 'El Aoun',
            'TP': 'Moktar/Elhacen'
        }
    },
    {
        'code': 'IRT35',
        'title': 'Architecture des ordinateurs',
        'credits': 3,
        'cm_hours': 8,
        'td_hours': 8,
        'tp_hours': 8,
        'professors': {
            'CM': 'Sass',
            'TD': 'Sass',
            'TP': 'Sass'
        }
    },
    {
        'code': 'IRT37',
        'title': 'Réseaux d\'opérateurs',
        'credits': 2,
        'cm_hours': 5,
        'td_hours': 5,
        'tp_hours': 6,
        'professors': {
            'CM': 'El Aoun',
            'TD': 'El Aoun',
            'TP': 'El Aoun'
        }
    },
    {
        'code': 'IRT38',
        'title': 'IoT',
        'credits': 2,
        'cm_hours': 5,
        'td_hours': 5,
        'tp_hours': 6,
        'professors': {
            'CM': 'Elhacen',
            'TD': 'Elhacen',
            'TP': 'Helmi'
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
    
    for type_key, prof_name in course_data['professors'].items():
        if '/' in prof_name:
            prof_name = prof_name.split('/')[0]  # Take first professor for now
        CourseAssignment.objects.create(
            course=course,
            professor=professors[prof_name],
            type=type_key,
            room=room_104
        )

print("Initial data has been loaded successfully!")
