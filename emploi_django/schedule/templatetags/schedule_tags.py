from django import template
from django.template.defaultfilters import stringfilter

register = template.Library()

@register.filter
def get_item(dictionary_or_list, key):
    """Get item from dictionary or list by key/index"""
    if dictionary_or_list is None:
        return None
    if isinstance(dictionary_or_list, dict):
        return dictionary_or_list.get(key)
    if isinstance(dictionary_or_list, (list, tuple)) and isinstance(key, int):
        try:
            return dictionary_or_list[key]
        except (IndexError, TypeError):
            return None
    return None

@register.filter
def get_course_color(course, type_):
    """Get color based on course type with opacity for better visibility"""
    colors = {
        'CM': '#4CAF50',  # Material Green
        'TD': '#F44336',  # Material Red
        'TP': '#2196F3',  # Material Blue
        'SOUTENANCE': '#FF9800',  # Material Orange
        'MILITARY': '#9C27B0',  # Material Purple
    }
    return colors.get(str(type_), '#757575')  # Default to Material Grey

@register.filter
def format_time_period(period):
    """Format time period string"""
    periods = {
        'P1': '08:00 - 09:30',
        'P2': '09:45 - 11:15',
        'P3': '11:30 - 13:00',
        'P4': '15:10 - 16:40',
        'P5': '16:50 - 18:20'
    }
    return periods.get(period, period)
