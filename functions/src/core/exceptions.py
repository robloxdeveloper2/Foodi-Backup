"""
Custom Exceptions and Error Handlers
Provides standardized error handling for the Foodi application
"""

import logging
import uuid
from flask import jsonify, request
from werkzeug.exceptions import HTTPException
from marshmallow import ValidationError
from sqlalchemy.exc import IntegrityError

logger = logging.getLogger(__name__)

class AppError(Exception):
    """Base exception class for application errors"""
    
    def __init__(self, message: str, status_code: int = 500, error_code: str = None):
        super().__init__(message)
        self.message = message
        self.status_code = status_code
        self.error_code = error_code or self.__class__.__name__
        self.error_id = str(uuid.uuid4())

class ValidationError(AppError):
    """Raised when data validation fails"""
    
    def __init__(self, message: str, field: str = None):
        super().__init__(message, status_code=400)
        self.field = field

class AuthenticationError(AppError):
    """Raised when authentication fails"""
    
    def __init__(self, message: str = "Authentication failed"):
        super().__init__(message, status_code=401)

class AuthorizationError(AppError):
    """Raised when authorization fails"""
    
    def __init__(self, message: str = "Access denied"):
        super().__init__(message, status_code=403)

class NotFoundError(AppError):
    """Raised when a resource is not found"""
    
    def __init__(self, message: str = "Resource not found"):
        super().__init__(message, status_code=404)

class UserNotFoundError(NotFoundError):
    """Raised when a user is not found"""
    
    def __init__(self, message: str = "User not found"):
        super().__init__(message)

class UserAlreadyExistsError(AppError):
    """Raised when trying to create a user that already exists"""
    
    def __init__(self, message: str = "User already exists"):
        super().__init__(message, status_code=409)

class EmailNotVerifiedError(AppError):
    """Raised when email verification is required"""
    
    def __init__(self, message: str = "Email verification required"):
        super().__init__(message, status_code=403)

class InvalidTokenError(AppError):
    """Raised when a token is invalid or expired"""
    
    def __init__(self, message: str = "Invalid or expired token"):
        super().__init__(message, status_code=401)

class ExternalServiceError(AppError):
    """Raised when an external service fails"""
    
    def __init__(self, message: str = "External service unavailable"):
        super().__init__(message, status_code=502)

def register_error_handlers(app):
    """Register error handlers with the Flask application"""
    
    @app.errorhandler(AppError)
    def handle_app_error(error: AppError):
        """Handle custom application errors"""
        logger.error(
            f"AppError occurred: {error.error_code} - {error.message}",
            extra={
                'error_id': error.error_id,
                'error_code': error.error_code,
                'status_code': error.status_code,
                'request_path': request.path,
                'request_method': request.method,
                'user_agent': request.headers.get('User-Agent'),
                'ip_address': request.remote_addr
            }
        )
        
        response = {
            'error': {
                'code': error.error_code,
                'message': error.message,
                'error_id': error.error_id
            },
            'success': False
        }
        
        if hasattr(error, 'field') and error.field:
            response['error']['field'] = error.field
        
        return jsonify(response), error.status_code
    
    @app.errorhandler(ValidationError)
    def handle_validation_error(error):
        """Handle validation errors (both custom and Marshmallow)"""
        error_id = str(uuid.uuid4())
        
        # Check if it's a Marshmallow validation error (has messages attribute)
        if hasattr(error, 'messages'):
            logger.warning(
                f"Marshmallow validation error: {error.messages}",
                extra={
                    'error_id': error_id,
                    'validation_errors': error.messages,
                    'request_path': request.path,
                    'request_method': request.method
                }
            )
            
            return jsonify({
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': error.messages,
                    'error_id': error_id
                },
                'success': False
            }), 400
        
        # Handle our custom ValidationError (has message attribute)
        else:
            logger.warning(
                f"Custom validation error: {error.message}",
                extra={
                    'error_id': error_id,
                    'request_path': request.path,
                    'request_method': request.method
                }
            )
            
            return jsonify({
                'error': {
                    'code': 'ValidationError',
                    'message': error.message,
                    'error_id': error_id
                },
                'success': False
            }), 400
    
    @app.errorhandler(IntegrityError)
    def handle_integrity_error(error):
        """Handle database integrity errors"""
        error_id = str(uuid.uuid4())
        
        logger.error(
            f"Database integrity error: {str(error)}",
            extra={
                'error_id': error_id,
                'request_path': request.path,
                'request_method': request.method
            }
        )
        
        # Check for common integrity constraint violations
        error_message = "Data integrity error"
        if 'unique constraint' in str(error).lower():
            if 'email' in str(error).lower():
                error_message = "Email address is already registered"
            elif 'username' in str(error).lower():
                error_message = "Username is already taken"
            else:
                error_message = "Duplicate data detected"
        
        return jsonify({
            'error': {
                'code': 'IntegrityError',
                'message': error_message,
                'error_id': error_id
            },
            'success': False
        }), 409
    
    @app.errorhandler(HTTPException)
    def handle_http_exception(error):
        """Handle HTTP exceptions"""
        error_id = str(uuid.uuid4())
        
        logger.warning(
            f"HTTP exception: {error.code} - {error.description}",
            extra={
                'error_id': error_id,
                'status_code': error.code,
                'request_path': request.path,
                'request_method': request.method
            }
        )
        
        return jsonify({
            'error': {
                'code': f'HTTP{error.code}',
                'message': error.description,
                'error_id': error_id
            },
            'success': False
        }), error.code
    
    @app.errorhandler(Exception)
    def handle_generic_exception(error):
        """Handle unexpected exceptions"""
        error_id = str(uuid.uuid4())
        
        logger.error(
            f"Unexpected error: {str(error)}",
            extra={
                'error_id': error_id,
                'error_type': type(error).__name__,
                'request_path': request.path,
                'request_method': request.method
            },
            exc_info=True
        )
        
        return jsonify({
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred',
                'error_id': error_id
            },
            'success': False
        }), 500 