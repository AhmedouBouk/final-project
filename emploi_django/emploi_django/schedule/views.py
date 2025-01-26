from django.shortcuts import redirect, render, get_object_or_404
from django.http import JsonResponse
from django.views.generic import ListView
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ObjectDoesNotExist
import json
from .models import Course, Professor, Room, CourseAssignment, TimeSlot, Department, Semester
import logging

logger = logging.getLogger(__name__)
def home(request):
    """View for the home page"""
    if request.user.is_authenticated:
        if hasattr(request.user, 'profile'):
            profile = request.user.profile
            if profile.role.startswith('CHEF_'):
                return redirect('semester_select', department_code=profile.department.code)
            else:
                return redirect('select_department')
        else:
            return redirect('select_department')
    else:
        return render(request, 'schedule/home.html')

def department_dashboard(request, department_code):
    """View for the department dashboard"""
    department = get_object_or_404(Department, code=department_code)
    context = {
        'department': department,
    }
    return render(request, 'schedule/department_dashboard.html', context)
def select_department(request):
    if hasattr(request.user, 'profile'):
            profile = request.user.profile
            if profile.role.startswith('CHEF_'):
                return redirect('department_dashboard', department_code=profile.department.code)
           
    """View for selecting department"""
    departments = Department.objects.all()
    return render(request, 'schedule/department_select.html', {'departments': departments})
def department_dashboard(request, department_code):
    """View for the department dashboard"""
    department = get_object_or_404(Department, code=department_code)
    
    # Ajoutez ici la logique pour afficher le tableau de bord du département
    context = {
        'department': department,
    }
    return render(request, 'schedule/department_dashboard.html', context)
def select_semester(request, department_code):
    """View for selecting semester within a department"""
    department = get_object_or_404(Department, code=department_code)
    semesters = Semester.objects.filter(department=department)
    if not semesters.exists():
        # Create semesters if they don't exist
        for code, _ in Semester.SEMESTER_CHOICES:
            Semester.objects.create(code=code, department=department)
        semesters = Semester.objects.filter(department=department)
    return render(request, 'schedule/semester_select.html', {
        'department': department,
        'semesters': semesters
    })
from django.contrib.auth.decorators import login_required

@login_required
def view_schedule(request, department_code, semester_code):
    """View for displaying the weekly schedule"""
    department = get_object_or_404(Department, code=department_code)
    semester = get_object_or_404(Semester, department=department, code=semester_code)
    courses = Course.objects.filter(department=department, semester=semester)
    professors = Professor.objects.all()
    rooms = Room.objects.all()
    
    # Get all time slots for this department's courses
    course_assignments = CourseAssignment.objects.filter(course__in=courses)
    time_slots = TimeSlot.objects.filter(course_assignment__in=course_assignments)
    
    # Convert time slots to JSON for the schedule
    schedule_data = []
    for slot in time_slots:
        professor_name = slot.course_assignment.professor.name if slot.course_assignment.professor else 'Non assigné'
        schedule_data.append({
            'day': slot.day,
            'period': slot.period,
            'week': slot.week,
            'course': slot.course_assignment.course.code,
            'professor': professor_name,
            'type': slot.course_assignment.type,
            'room': slot.course_assignment.room.number if slot.course_assignment.room else ''
        })
    
    context = {
        'department': department,
        'semester': semester,
        'courses': courses,
        'professors': professors,
        'rooms': rooms,
        'schedule_data': json.dumps(schedule_data),
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 17)
    }
    return render(request, 'schedule/schedule.html', context)

def view_bilan(request, department_code, semester_code):
    """View for displaying the course progress"""
    try:
        department = get_object_or_404(Department, code=department_code)
        semester = get_object_or_404(Semester, department=department, code=semester_code)
        courses = Course.objects.filter(department=department, semester=semester)
        
        context = {
            'department': department,
            'semester': semester,
            'courses': courses,
        }
        return render(request, 'schedule/bilan.html', context)
    except Exception as e:
        return render(request, 'schedule/bilan.html', {
            'courses': [],
            'error_message': "Une erreur s'est produite lors du chargement des données.",
            'department': get_object_or_404(Department, code=department_code),
            'semester': get_object_or_404(Semester, department=get_object_or_404(Department, code=department_code), code=semester_code),
        })
@login_required
def view_plan(request, department_code, semester_code):
    """View for managing the schedule plan"""
    department = get_object_or_404(Department, code=department_code)
    semester = get_object_or_404(Semester, department=department, code=semester_code)
    courses = Course.objects.filter(department=department, semester=semester)
    
    # Update completion status for all courses
    for course in courses:
        course.update_completed_hours()
    
    context = {
        'department': department,
        'semester': semester,
        'courses': courses,
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 17)
    }
    return render(request, 'schedule/plan.html', context)

class CourseListView(ListView):
    template_name = 'schedule/database.html'
    context_object_name = 'courses'

    def get_queryset(self):
        department_code = self.kwargs['department_code']
        semester_code = self.kwargs['semester_code']
        return Course.objects.filter(department__code=department_code, semester__code=semester_code)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        department_code = self.kwargs['department_code']
        semester_code = self.kwargs['semester_code']
        department = get_object_or_404(Department, code=department_code)
        semester = get_object_or_404(Semester, department=department, code=semester_code)
        context['department'] = department
        context['semester'] = semester
        return context

# API Views
def get_courses(request, department_code, semester_code):
    """Get list of courses for a department and semester"""
    courses = Course.objects.filter(
        department__code=department_code,
        semester__code=semester_code
    ).values('code', 'title')
    return JsonResponse({'courses': list(courses)})

def get_course_info(request, department_code, semester_code, code):
    """Get, update, or delete course information"""
    try:
        if request.method == 'GET':
            course = Course.objects.get(pk=code, department__code=department_code, semester__code=semester_code)
            assignments = CourseAssignment.objects.filter(course=course)
            data = {
                'code': course.code,
                'title': course.title,
                'credits': course.credits,
                'cm_hours': course.cm_hours,
                'td_hours': course.td_hours,
                'tp_hours': course.tp_hours,
                'assignments': [{
                    'professor': assignment.professor.name,
                    'type': assignment.type,
                    'room': assignment.room.number if assignment.room else None
                } for assignment in assignments]
            }
            return JsonResponse(data)
            
        elif request.method == 'POST':
            data = json.loads(request.body)
            course, created = Course.objects.update_or_create(
                code=code,
                department__code=department_code,
                semester__code=semester_code,
                defaults={
                    'title': data['title'],
                    'credits': data['credits'],
                    'cm_hours': data['cm_hours'],
                    'td_hours': data['td_hours'],
                    'tp_hours': data['tp_hours']
                }
            )
            
            # Handle assignments
            CourseAssignment.objects.filter(course=course).delete()
            for assignment_data in data.get('assignments', []):
                professor = Professor.objects.get_or_create(name=assignment_data['professor'])[0]
                room = None
                if assignment_data.get('room'):
                    room = Room.objects.get_or_create(
                        number=assignment_data['room'],
                        defaults={'type': assignment_data['type']}
                    )[0]
                
                CourseAssignment.objects.create(
                    course=course,
                    professor=professor,
                    type=assignment_data['type'],
                    room=room
                )
            
            return JsonResponse({'status': 'success'})
            
        elif request.method == 'DELETE':
            course = Course.objects.get(pk=code, department__code=department_code, semester__code=semester_code)
            course.delete()
            return JsonResponse({'status': 'success'})
            
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def get_professors(request, department_code, semester_code):
    """Get all professors for a department and semester"""
    professors = Professor.objects.filter(courses__department__code=department_code, courses__semester__code=semester_code).distinct()
    data = [{'id': prof.id, 'name': prof.name} for prof in professors]
    return JsonResponse(data, safe=False)

def get_rooms(request, department_code, semester_code):
    """Get all rooms"""
    rooms = Room.objects.all()
    data = [{'id': room.id, 'number': room.number, 'type': room.type} for room in rooms]
    return JsonResponse(data, safe=False)

def get_schedule(request, department_code, semester_code, week):
    """Get schedule for a specific week"""
    slots = TimeSlot.objects.filter(
        course_assignment__course__department__code=department_code,
        course_assignment__course__semester__code=semester_code,
        week=week
    ).select_related('course_assignment', 'course_assignment__course', 'course_assignment__professor', 'course_assignment__room')
    
    schedule = []
    for slot in slots:
        professor_name = slot.course_assignment.professor.name if slot.course_assignment.professor else 'Non assigné'
        schedule.append({
            'day': slot.day,
            'period': slot.period,
            'course': slot.course_assignment.course.code,
            'professor': professor_name,
            'room': slot.course_assignment.room.number if slot.course_assignment.room else None,
            'type': slot.course_assignment.type
        })
    return JsonResponse({'schedule': schedule})

def get_all_plan(request, department_code, semester_code):
    """Get plan for all weeks"""
    slots = TimeSlot.objects.filter(
        course_assignment__course__department__code=department_code,
        course_assignment__course__semester__code=semester_code
    ).select_related(
        'course_assignment',
        'course_assignment__course',
        'course_assignment__professor',
        'course_assignment__room'
    )
    
    data = []
    logger.info(f"Retrieved {len(slots)} slots from the database")
    for slot in slots:
        logger.info(f"Processing slot: {slot.id}, Type: {slot.course_assignment.type}, Special: {slot.course_assignment.is_special}")
        if slot.course_assignment.is_special:
            logger.info(f"Special course found: {slot.course_assignment.description}")
            data.append({
                'week': slot.week,
                'day': slot.day,
                'period': slot.period,
                'course_code': 'SPECIAL',
                'type': slot.course_assignment.type,
                'description': slot.course_assignment.description
            })
        else:
            if slot.course_assignment.course:
                logger.info(f"Regular course found: {slot.course_assignment.course.code}")
                data.append({
                    'week': slot.week,
                    'day': slot.day,
                    'period': slot.period,
                    'course_code': slot.course_assignment.course.code,
                    'type': slot.course_assignment.type,
                    'professor': slot.course_assignment.professor.name if slot.course_assignment.professor else 'Non assigné',
                    'room': slot.course_assignment.room.number if slot.course_assignment.room else None
                })
    return JsonResponse(data, safe=False)
def get_plan(request, department_code, semester_code, week):
    """Get plan for a specific week"""
    slots = TimeSlot.objects.filter(
        course_assignment__course__department__code=department_code,
        course_assignment__course__semester__code=semester_code,
        week=week
    ).select_related(
        'course_assignment',
        'course_assignment__course',
        'course_assignment__professor',
        'course_assignment__room'
    )
    
    plan = []
    for slot in slots:
        professor_name = slot.course_assignment.professor.name if slot.course_assignment.professor else 'Non assigné'
        plan.append({
            'day': slot.day,
            'period': slot.period,
            'course_code': slot.course_assignment.course.code,
            'type': slot.course_assignment.type,
            'professor': professor_name,
            'room': slot.course_assignment.room.number if slot.course_assignment.room else None
        })
    return JsonResponse(plan, safe=False)
@csrf_exempt
def save_plan(request, department_code, semester_code):
    """Save the planning data"""
    if request.method == 'POST':
        try:
            # Vérifier les permissions
            check_chef_departement_permission(request.user, department_code)


            # Convertir les données de la requête
            body = request.body.decode('utf-8')
            logger.info(f"Raw request body: {body}")
            
            try:
                data = json.loads(body)
            except json.JSONDecodeError as e:
                logger.error(f"JSON Decode Error: {e}")
                return JsonResponse({
                    'status': 'error',
                    'message': f'Invalid JSON: {str(e)}'
                }, status=400)
            
            # ... (le reste de la logique)
            
        except PermissionDenied as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=403)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)
    
    
@csrf_exempt
def update_course(request, department_code, semester_code):  # Fix parameter name here
    """Update course information and assignments"""
    if request.method == 'POST':
        try:
            # 1. Check permissions
            check_chef_departement_permission(request.user, department_code)
            
            # 2. Parse data
            data = json.loads(request.body)
            code = data.get('code')
            updates = data.get('updates', {})
            
            # 3. Fetch department and semester
            department = Department.objects.get(code=department_code)
            semester = Semester.objects.get(code=semester_code, department=department)  # Use semester_code
            
            # 4. Fetch the course
            course = Course.objects.get(
                code=code,
                department=department,
                semester=semester
            )
            
            # 5. Update basic fields
            for field in ['title', 'credits', 'cm_hours', 'td_hours', 'tp_hours']:
                if field in updates:
                    setattr(course, field, updates[field])
            course.save()
            
            # 6. Update assignments
            for assignment_type in ['CM', 'TD', 'TP']:
                professor_name = updates.get(f'{assignment_type.lower()}_professor')
                room_number = updates.get(f'{assignment_type.lower()}_room')
                
                # Get or create assignment
                assignment, _ = CourseAssignment.objects.get_or_create(
                    course=course,
                    type=assignment_type,
                    defaults={'department': department, 'semester': semester}
                )
                
                # Update professor
                if professor_name:
                    professor, _ = Professor.objects.get_or_create(name=professor_name.strip())
                    assignment.professor = professor
                else:
                    assignment.professor = None
                
                # Update room
                if room_number:
                    room, _ = Room.objects.get_or_create(
                        number=room_number.strip(),
                        defaults={'type': assignment_type}
                    )
                    assignment.room = room
                else:
                    assignment.room = None
                
                assignment.save()
            
            return JsonResponse({'status': 'success', 'message': 'Course updated'})
            
        except (Department.DoesNotExist, Semester.DoesNotExist, Course.DoesNotExist) as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    
    return JsonResponse({'status': 'error', 'message': 'Invalid method'}, status=405)
@csrf_exempt
def delete_course(request, department_code, semester_code):
    """Delete a course"""
    if request.method == 'POST':
        try:
            # Check permissions
            check_chef_departement_permission(request.user, department_code)
            
            data = json.loads(request.body)
            code = data.get('code')
            
            if not code:
                return JsonResponse({
                    'error': 'Course code is required',
                    'status': 'error'
                }, status=400)
            
            # Delete the course
            course = Course.objects.get(
                code=code,
                department__code=department_code,
                semester__code=semester_code
            )
            course.delete()
            
            return JsonResponse({
                'message': f'Course {code} deleted successfully',
                'status': 'success'
            })
            
        except Course.DoesNotExist:
            return JsonResponse({
                'error': 'Course not found',
                'status': 'error'
            }, status=404)
        except Exception as e:
            return JsonResponse({
                'error': str(e),
                'status': 'error'
            }, status=400)
    
    return JsonResponse({
        'error': 'Invalid request method',
        'status': 'error'
    }, status=405)

@csrf_exempt
def add_course(request, department_code, semester_code):
    """Add a new course to the database"""
    if request.method == 'POST':
        try:
            # Check permissions
            check_chef_departement_permission(request.user, department_code)
            
            data = json.loads(request.body)
            department = get_object_or_404(Department, code=department_code)
            semester = get_object_or_404(Semester, department=department, code=semester_code)

            # Validate required fields
            required_fields = ['code', 'title', 'credits', 'cm_hours', 'td_hours', 'tp_hours']
            if not all(field in data for field in required_fields):
                return JsonResponse({
                    'success': False,
                    'message': 'Missing required fields.'
                }, status=400)

            # Check for existing course code (globally unique)
            if Course.objects.filter(code=data['code']).exists():
                return JsonResponse({
                    'success': False,
                    'message': f"Course code {data['code']} already exists."
                }, status=400)

            # Create the course
            course = Course.objects.create(
                code=data['code'],
                title=data['title'],
                credits=data['credits'],
                cm_hours=data['cm_hours'],
                td_hours=data['td_hours'],
                tp_hours=data['tp_hours'],
                department=department,
                semester=semester
            )

            # Create CourseAssignment entries for professors and rooms
            for assignment_type in ['CM', 'TD', 'TP']:
                professor_name = data.get(f'{assignment_type.lower()}_professor')
                room_number = data.get(f'{assignment_type.lower()}_room')

                # Create professor if name is provided
                professor = None
                if professor_name:
                    professor, _ = Professor.objects.get_or_create(name=professor_name.strip())

                # Create room if number is provided
                room = None
                if room_number:
                    room, _ = Room.objects.get_or_create(
                        number=room_number.strip(),
                        defaults={'type': assignment_type}  # Set room type based on assignment
                    )

                # Create assignment if professor or room is provided
                if professor or room:
                    CourseAssignment.objects.create(
                        course=course,
                        type=assignment_type,
                        professor=professor,
                        room=room,
                        department=department,
                        semester=semester
                    )

            return JsonResponse({
                'success': True,
                'message': f"Course {course.code} added successfully."
            })

        except json.JSONDecodeError:
            return JsonResponse({
                'success': False,
                'message': 'Invalid JSON data.'
            }, status=400)
        except PermissionDenied as e:
            return JsonResponse({
                'success': False,
                'message': str(e)
            }, status=403)
        except Exception as e:
            return JsonResponse({
                'success': False,
                'message': str(e)
            }, status=400)

    return JsonResponse({
        'success': False,
        'message': 'Invalid request method.'
    }, status=405)
@csrf_exempt
@csrf_exempt
def save_slot(request, department_code, semester_code):
    """Save the planning data"""
    if request.method == 'POST':
        try:
            # Vérifier les permissions
            check_chef_departement_permission(request.user, department_code)

            # Convertir les données de la requête
            body = request.body.decode('utf-8')
            logger.info(f"Raw request body: {body}")
            
            try:
                data = json.loads(body)
            except json.JSONDecodeError as e:
                logger.error(f"JSON Decode Error: {e}")
                return JsonResponse({
                    'status': 'error',
                    'message': f'Invalid JSON: {str(e)}'
                }, status=400)
            
            # Ensure the data is a list
            if not isinstance(data, list):
                logger.error(f"Invalid data format. Expected list, got {type(data)}")
                return JsonResponse({
                    'status': 'error',
                    'message': 'Invalid data format. Expected a list of slots.'
                }, status=400)
            
            # Fetch the department and semester
            try:
                department = Department.objects.get(code=department_code)
                semester = Semester.objects.get(department=department, code=semester_code)
            except Department.DoesNotExist:
                logger.error(f"Department not found: {department_code}")
                return JsonResponse({
                    'status': 'error',
                    'message': f'Department {department_code} not found'
                }, status=400)
            except Semester.DoesNotExist:
                logger.error(f"Semester not found: {semester_code}")
                return JsonResponse({
                    'status': 'error',
                    'message': f'Semester {semester_code} not found'
                }, status=400)
            
            # Process each slot in the data
            for slot_data in data:
                # Validate required fields
                required_keys = ['week', 'day', 'period', 'type']
                if not all(key in slot_data for key in required_keys):
                    missing_keys = [key for key in required_keys if key not in slot_data]
                    logger.error(f"Incomplete slot data. Missing keys: {missing_keys}")
                    return JsonResponse({
                        'status': 'error',
                        'message': f'Incomplete slot data. Missing keys: {missing_keys}'
                    }, status=400)
                
                # Handle special courses
                slot_type = slot_data['type'].upper()
                if slot_type == 'SPECIAL':
                    course_assignment = CourseAssignment.objects.create(
                        type='SPECIAL',
                        is_special=True,
                        description=slot_data.get('description', ''),
                        department=department,  # Associer au département
                        semester=semester  # Associer au semestre
                    )
                    logger.info(f"Special CourseAssignment created: {course_assignment}")
                else:
                    # Handle regular courses
                    if 'course_code' not in slot_data:
                        logger.error("Course code is required for non-special slots")
                        return JsonResponse({
                            'status': 'error',
                            'message': 'Course code is required for non-special slots'
                        }, status=400)
                    
                    try:
                        course = Course.objects.get(
                            code=slot_data['course_code'],
                            department=department,
                            semester=semester
                        )
                    except Course.DoesNotExist:
                        logger.error(f"Course not found: {slot_data['course_code']}")
                        return JsonResponse({
                            'status': 'error',
                            'message': f"Course {slot_data['course_code']} not found"
                        }, status=400)
                    
                    # Get or create the course assignment
                    course_assignment, created = CourseAssignment.objects.get_or_create(
                        course=course,
                        type=slot_data['type']
                    )
                    logger.info(f"Course assignment {'created' if created else 'found'}: {course_assignment}")
                
                # Ensure course_assignment is not None
                if not course_assignment:
                    logger.error(f"Course assignment is None for slot: {slot_data}")
                    return JsonResponse({
                        'status': 'error',
                        'message': 'Course assignment is None'
                    }, status=400)
                
                # Delete existing slots for the same time period and course assignment
                existing_slots = TimeSlot.objects.filter(
                    week=slot_data['week'],
                    day=slot_data['day'],
                    period=slot_data['period'],
                    course_assignment=course_assignment  # Only delete slots for the same course assignment
                )
                logger.info(f"Existing slots to delete: {existing_slots.count()}")
                existing_slots.delete()
                
                # Create the new TimeSlot
                try:
                    new_slot = TimeSlot.objects.create(
                        course_assignment=course_assignment,
                        week=slot_data['week'],
                        day=slot_data['day'],
                        period=slot_data['period']
                    )
                    logger.info(f"New slot created: {new_slot}")
                except Exception as e:
                    logger.error(f"Error creating slot: {e}")
                    return JsonResponse({
                        'status': 'error',
                        'message': f'Error creating slot: {str(e)}'
                    }, status=400)
            
            return JsonResponse({'status': 'success'})
        
        except PermissionDenied as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=403)
        
        except Exception as e:
            logger.error(f"Unexpected error: {e}", exc_info=True)
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=400)
    
    return JsonResponse({
        'status': 'error',
        'message': 'Invalid request method'
    }, status=405)

#modifier
import logging
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.core.exceptions import PermissionDenied
import json
from .models import Department, Semester, TimeSlot

logger = logging.getLogger(__name__)
@csrf_exempt
def delete_slot(request, department_code, semester_code):
    """Delete a time slot"""
    if request.method == 'POST':
        try:
            # Vérifier les permissions
            check_chef_departement_permission(request.user, department_code)
            
            # Charger les données JSON
            data = json.loads(request.body)
            logger.info(f"Data received: {data}")
            
            # Récupérer le département et le semestre
            department = get_object_or_404(Department, code=department_code)
            semester = get_object_or_404(Semester, department=department, code=semester_code)
            
            # Trouver le time slot
            time_slot = TimeSlot.objects.get(
                course_assignment__course__department=department,
                course_assignment__course__semester=semester,
                week=data['week'],
                day=data['day'],
                period=data['period']
            )
            
            # Supprimer le time slot
            time_slot.delete()
            logger.info(f"Time slot deleted: {data}")
            
            return JsonResponse({
                'status': 'success',
                'message': 'Time slot deleted successfully'
            })
            
        except PermissionDenied as e:
            logger.error(f"Permission denied: {e}")
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=403)
            
        except TimeSlot.DoesNotExist:
            logger.error("Time slot not found")
            return JsonResponse({
                'status': 'error',
                'message': 'Time slot not found'
            }, status=404)
            
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=400)
    
    return JsonResponse({
        'status': 'error',
        'message': 'Invalid request method'
    }, status=405)
@csrf_exempt
def update_bilan(request, department_code, semester_code):
    """Update course completion values"""
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)
    
    try:
        # Vérifier les permissions
        check_chef_departement_permission(request.user)
        
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except PermissionDenied as e:
        return JsonResponse({'error': str(e)}, status=403)
    
    try:
        course_code = data.get('course_code')
        field = data.get('field')
        value = data.get('value')
        
        # Valider les champs requis
        if not all([course_code, field, value is not None]):
            return JsonResponse({
                'error': 'Missing required fields'
            }, status=400)
        
        # Valider le nom du champ
        valid_fields = ['cm_completed', 'td_completed', 'tp_completed']
        if field not in valid_fields:
            return JsonResponse({
                'error': f'Invalid field name. Must be one of: {", ".join(valid_fields)}'
            }, status=400)
        
        try:
            value = float(value)
        except (TypeError, ValueError):
            return JsonResponse({'error': str(e)}, status=400)

        # Obtenir et mettre à jour le cours
        course = Course.objects.get(code=course_code, department__code=department_code, semester__code=semester_code)
        
        # Valider par rapport aux heures planifiées
        planned_hours = getattr(course, field.replace('completed', 'hours'))
        if value > planned_hours:
            return JsonResponse({
                'error': f'Completed hours ({value}) cannot exceed planned hours ({planned_hours})'
            }, status=400)
        
        # Mettre à jour le champ
        setattr(course, field, value)
        course.save()
        
        # Retourner les valeurs de progression mises à jour
        return JsonResponse({
            'status': 'success',
            'progress': {
                'cm': course.progress_cm(),
                'td': course.progress_td(),
                'tp': course.progress_tp(),
                'total': course.total_progress()
            }
        })
        
    except Course.DoesNotExist:
        return JsonResponse({
            'error': f'Course with code {course_code} not found'
        }, status=404)
        
    except Exception as e:
        logger.error(f"Error in update_bilan: {str(e)}")
        return JsonResponse({'error': 'Server error'}, status=500)
from django.core.exceptions import PermissionDenied

def is_chef_departement(user, department_code):
    """Check if the user is a chef de département"""
    # First, ensure the user has a profile
    if not hasattr(user, 'profile'):
        return False
    
    # Check if the user's role starts with 'CHEF_'
    if not user.profile.role.startswith('CHEF_'):
        return False
    
    # If a specific department code is provided, check it matches
    if department_code:
        return (user.profile.department and 
                user.profile.department.code == department_code)
    
    return True

def check_chef_departement_permission(user,department_code):
    """Raise PermissionDenied if the user is not a chef de département"""
    if not is_chef_departement(user,department_code):
        raise PermissionDenied("Seuls les chefs de département peuvent effectuer cette action.")
from django.shortcuts import redirect
from django.contrib.auth import views as auth_views
from django.contrib.auth.decorators import login_required

from django.shortcuts import redirect
from django.contrib.auth import views as auth_views
from django.contrib import messages

class CustomLoginView(auth_views.LoginView):
    """Custom login view that redirects authenticated users"""
    template_name = 'registration/login.html'

    def dispatch(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            messages.warning(request, 'Vous êtes déjà connecté.')
            return redirect('home')  # Redirige vers la page d'accueil
        return super().dispatch(request, *args, **kwargs)