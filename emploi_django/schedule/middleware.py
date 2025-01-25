from django.shortcuts import redirect
from django.urls import reverse
from django.contrib.auth.views import redirect_to_login

class AuthenticationMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if not request.user.is_authenticated and not request.path == reverse('login'):
            if request.path.startswith('/admin/'):
                return redirect_to_login(request.path)
            return redirect('login')
        
        # Check department access
        if request.user.is_authenticated and not request.user.is_superuser:
            path_parts = request.path.split('/')
            if len(path_parts) > 1 and path_parts[1]:
                department_code = path_parts[1]
                if not request.user.has_department_access(department_code):
                    if request.user.department:
                        return redirect('semester_select', department_code=request.user.department.code)
                    return redirect('department_select')

        response = self.get_response(request)
        return response
