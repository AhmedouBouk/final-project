from django.db import models
from django.forms import ValidationError

# Create your models here.

class Department(models.Model):
    code = models.CharField(max_length=10, primary_key=True)  # e.g., IRT, GM
    name = models.CharField(max_length=100)  # e.g., Informatique, Réseaux et Télécommunications

    def __str__(self):
        return self.name

class Semester(models.Model):
    SEMESTER_CHOICES = [
        ('S1', 'Semester 1'),
        ('S2', 'Semester 2'),
        ('S3', 'Semester 3'),
        ('S4', 'Semester 4'),
    ]
    code = models.CharField(max_length=2, choices=SEMESTER_CHOICES)
    department = models.ForeignKey(Department, on_delete=models.CASCADE, related_name='semesters')

    def __str__(self):
        return f"{self.department.code} - {self.get_code_display()}"

    class Meta:
        unique_together = ('code', 'department')

def get_default_department():
    dept, _ = Department.objects.get_or_create(
        code='DEFAULT',
        defaults={'name': 'Default Department'}
    )
    return dept.code

def get_default_semester():
    dept, _ = Department.objects.get_or_create(
        code='DEFAULT',
        defaults={'name': 'Default Department'}
    )
    semester, _ = Semester.objects.get_or_create(
        code='S1',
        department=dept
    )
    return semester.id

class Course(models.Model):
    code = models.CharField(max_length=10, primary_key=True)  # e.g., IRT31
    department = models.ForeignKey(Department, on_delete=models.CASCADE, related_name='courses', default=get_default_department)
    semester = models.ForeignKey(Semester, on_delete=models.CASCADE, related_name='courses', default=get_default_semester)
    title = models.CharField(max_length=100)
    credits = models.IntegerField()
    cm_hours = models.IntegerField()  # Total planned CM hours
    td_hours = models.IntegerField()  # Total planned TD hours
    tp_hours = models.IntegerField()  # Total planned TP hours
    cm_completed = models.IntegerField(default=0)  # Completed CM hours
    td_completed = models.IntegerField(default=0)  # Completed TD hours
    tp_completed = models.IntegerField(default=0)  # Completed TP hours
    exam_sn = models.FloatField(null=True, blank=True)
    exam_sr = models.FloatField(null=True, blank=True)

    def __str__(self):
        return f"{self.code} - {self.title}"

    def update_completed_hours(self):
        """Update completed hours based on scheduled sessions"""
        assignments = CourseAssignment.objects.filter(course=self)
        self.cm_completed = 0
        self.td_completed = 0
        self.tp_completed = 0
        
        for assignment in assignments:
            slots = TimeSlot.objects.filter(course_assignment=assignment)
            if assignment.type == 'CM':
                self.cm_completed = slots.count() * 1.5
            elif assignment.type == 'TD':
                self.td_completed = slots.count() * 1.5
            elif assignment.type == 'TP':
                self.tp_completed = slots.count() * 1.5
        
        self.save()

    def progress_cm(self):
        """Calculate CM progress percentage"""
        if self.cm_hours == 0:
            return 100
        return int((self.cm_completed / self.cm_hours) * 100)

    def progress_td(self):
        """Calculate TD progress percentage"""
        if self.td_hours == 0:
            return 100
        return int((self.td_completed / self.td_hours) * 100)

    def progress_tp(self):
        """Calculate TP progress percentage"""
        if self.tp_hours == 0:
            return 100
        return int((self.tp_completed / self.tp_hours) * 100)

    def total_progress(self):
        """Calculate total progress percentage"""
        total_planned = self.cm_hours + self.td_hours + self.tp_hours
        if total_planned == 0:
            return 100
        total_completed = self.cm_completed + self.td_completed + self.tp_completed
        return int((total_completed / total_planned) * 100)

class Professor(models.Model):
    name = models.CharField(max_length=100)
    courses = models.ManyToManyField(Course, through='CourseAssignment')

    def __str__(self):
        return self.name

class Room(models.Model):
    number = models.CharField(max_length=20)
    type = models.CharField(max_length=20)  # CM, TD, TP

    def __str__(self):
        return f"{self.number} ({self.type})"

class CourseAssignment(models.Model):
    TYPES = [
        ('CM', 'Cours Magistral'),
        ('TD', 'Travaux Dirigés'),
        ('TP', 'Travaux Pratiques'),
        ('DS', 'Devoir Surveillé'),
        ('EXAM', 'Examen'),
        ('SPECIAL', 'Cours Spécial')
    ]
    
    course = models.ForeignKey(Course, on_delete=models.CASCADE, null=True, blank=True)
    type = models.CharField(max_length=20, choices=TYPES)
    professor = models.ForeignKey(Professor, on_delete=models.SET_NULL, null=True, blank=True)
    room = models.ForeignKey(Room, on_delete=models.SET_NULL, null=True, blank=True)
    is_special = models.BooleanField(default=False)
    description = models.CharField(max_length=255, null=True, blank=True)
    department = models.ForeignKey(Department, on_delete=models.CASCADE, null=True, blank=True)  # Ajout
    semester = models.ForeignKey(Semester, on_delete=models.CASCADE, null=True, blank=True)  # Ajout

    def __str__(self):
        if self.is_special:
            return f"{self.description} ({self.type})"
        return f"{self.course.code} - {self.professor.name if self.professor else 'No Professor'} ({self.type})"

class TimeSlot(models.Model):
    DAYS = [
        ('LUN', 'Lundi'),
        ('MAR', 'Mardi'),
        ('MER', 'Mercredi'),
        ('JEU', 'Jeudi'),
        ('VEN', 'Vendredi'),
        ('SAM', 'Samedi')
    ]
    PERIODS = [
        ('P1', '08h30 à 10h00'),
        ('P2', '10h10 à 11h40'),
        ('P3', '13h30 à 15h00'),
        ('P4', '15h10 à 16h40'),
        ('P5', '16h50 à 18h20')
    ]
    
    day = models.CharField(max_length=3, choices=DAYS)
    period = models.CharField(max_length=2, choices=PERIODS)
    week = models.IntegerField()  # Week number
    course_assignment = models.ForeignKey(
        CourseAssignment, 
        on_delete=models.CASCADE, 
        related_name='time_slots',
        null=True, 
        blank=True
    )

    class Meta:
        # Aucune contrainte unique
        pass

    def __str__(self):
        if self.course_assignment:
            if self.course_assignment.is_special:
                return f"{self.course_assignment.description} (SPECIAL) - {self.day} {self.period} (Week {self.week})"
            elif hasattr(self.course_assignment, 'course') and self.course_assignment.course:
                return f"{self.course_assignment.course.code} - {self.day} {self.period} (Week {self.week})"
        return f"No Course - {self.day} {self.period} (Week {self.week})"   
from django.contrib.auth.models import User
from django.db import models

class Profile(models.Model):
    ROLE_CHOICES = [
        ('STUDENT', 'Étudiant'),
        ('CHEF_IRT', 'Chef de département IRT'),
        ('CHEF_GC', 'Chef de département GC'),
        ('CHEF_GE', 'Chef de département GE'),
        ('CHEF_GM', 'Chef de département GM'),
        ('CHEF_MPG', 'Chef de département MPG'),
        ('CHEF_SUD', 'Chef de département SUD'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.get_role_display()}"

    def is_chef_departement(self):
        """Check if the user is a chef de département"""
        return self.role.startswith('CHEF_')

    def is_student(self):
        """Check if the user is a student"""
        return self.role == 'STUDENT'
    