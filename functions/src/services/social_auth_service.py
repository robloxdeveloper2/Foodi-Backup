"""
Social Authentication Service
Handles Google and Apple social login verification
"""

import os
import requests
import logging
from typing import Dict, Any, Optional
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

from core.exceptions import ExternalServiceError, AuthenticationError

logger = logging.getLogger(__name__)

class SocialAuthService:
    """Service for social authentication providers"""
    
    def __init__(self):
        self.google_client_id = os.getenv('GOOGLE_CLIENT_ID')
        self.google_client_secret = os.getenv('GOOGLE_CLIENT_SECRET')
        self.apple_client_id = os.getenv('APPLE_CLIENT_ID')
        self.apple_client_secret = os.getenv('APPLE_CLIENT_SECRET')
    
    def verify_token(self, provider: str, access_token: str) -> Dict[str, Any]:
        """
        Verify social login token and get user information
        
        Args:
            provider: Social provider (google, apple)
            access_token: Provider access token
            
        Returns:
            Dictionary containing user information
            
        Raises:
            AuthenticationError: If token verification fails
            ExternalServiceError: If provider service is unavailable
        """
        logger.info(f"Verifying {provider} token")
        
        if provider == 'google':
            return self._verify_google_token(access_token)
        elif provider == 'apple':
            return self._verify_apple_token(access_token)
        else:
            raise AuthenticationError(f"Unsupported social provider: {provider}")
    
    def _verify_google_token(self, access_token: str) -> Dict[str, Any]:
        """
        Verify Google OAuth token
        
        Args:
            access_token: Google access token or ID token
            
        Returns:
            Dictionary containing Google user information
            
        Raises:
            AuthenticationError: If token verification fails
            ExternalServiceError: If Google service is unavailable
        """
        try:
            # Try to verify as ID token first
            try:
                if self.google_client_id:
                    id_info = id_token.verify_oauth2_token(
                        access_token,
                        google_requests.Request(),
                        self.google_client_id
                    )
                    
                    return {
                        'id': id_info.get('sub'),
                        'email': id_info.get('email'),
                        'first_name': id_info.get('given_name'),
                        'last_name': id_info.get('family_name'),
                        'name': id_info.get('name'),
                        'picture': id_info.get('picture'),
                        'email_verified': id_info.get('email_verified', False)
                    }
            except Exception as e:
                logger.warning(f"Failed to verify as ID token, trying as access token: {str(e)}")
            
            # If ID token verification fails, try using access token to get user info
            response = requests.get(
                'https://www.googleapis.com/oauth2/v2/userinfo',
                headers={'Authorization': f'Bearer {access_token}'},
                timeout=10
            )
            
            if response.status_code == 200:
                user_info = response.json()
                return {
                    'id': user_info.get('id'),
                    'email': user_info.get('email'),
                    'first_name': user_info.get('given_name'),
                    'last_name': user_info.get('family_name'),
                    'name': user_info.get('name'),
                    'picture': user_info.get('picture'),
                    'email_verified': user_info.get('verified_email', False)
                }
            elif response.status_code == 401:
                raise AuthenticationError("Invalid Google token")
            else:
                raise ExternalServiceError("Google authentication service unavailable")
                
        except requests.RequestException as e:
            logger.error(f"Google API request failed: {str(e)}")
            raise ExternalServiceError("Google authentication service unavailable")
        except Exception as e:
            logger.error(f"Google token verification failed: {str(e)}")
            raise AuthenticationError("Invalid Google token")
    
    def _verify_apple_token(self, access_token: str) -> Dict[str, Any]:
        """
        Verify Apple Sign In token
        
        Args:
            access_token: Apple identity token (JWT)
            
        Returns:
            Dictionary containing Apple user information
            
        Raises:
            AuthenticationError: If token verification fails
            ExternalServiceError: If Apple service is unavailable
        """
        try:
            # Apple Sign In uses JWT tokens that need to be verified
            # This is a simplified implementation - in production, you would:
            # 1. Fetch Apple's public keys from https://appleid.apple.com/auth/keys
            # 2. Verify the JWT signature using those keys
            # 3. Validate the JWT claims (iss, aud, exp, etc.)
            
            # For now, we'll implement a basic verification
            # In a real application, use a library like PyJWT with Apple's public keys
            
            import jwt
            
            # Decode without verification for demo purposes
            # WARNING: This is not secure for production use
            decoded_token = jwt.decode(access_token, options={"verify_signature": False})
            
            # Validate basic claims
            if decoded_token.get('iss') != 'https://appleid.apple.com':
                raise AuthenticationError("Invalid Apple token issuer")
            
            if self.apple_client_id and decoded_token.get('aud') != self.apple_client_id:
                raise AuthenticationError("Invalid Apple token audience")
            
            # Extract user information
            user_id = decoded_token.get('sub')
            email = decoded_token.get('email')
            
            # Apple doesn't always provide name information in the token
            # Names are typically provided only on first sign-in
            name_info = decoded_token.get('name', {})
            
            return {
                'id': user_id,
                'email': email,
                'first_name': name_info.get('firstName'),
                'last_name': name_info.get('lastName'),
                'name': f"{name_info.get('firstName', '')} {name_info.get('lastName', '')}".strip(),
                'email_verified': decoded_token.get('email_verified', True)  # Apple emails are verified
            }
            
        except jwt.DecodeError as e:
            logger.error(f"Apple token decode failed: {str(e)}")
            raise AuthenticationError("Invalid Apple token format")
        except Exception as e:
            logger.error(f"Apple token verification failed: {str(e)}")
            raise AuthenticationError("Invalid Apple token")
    
    def get_google_oauth_url(self, redirect_uri: str, state: Optional[str] = None) -> str:
        """
        Generate Google OAuth authorization URL
        
        Args:
            redirect_uri: Redirect URI after authorization
            state: Optional state parameter
            
        Returns:
            Google OAuth authorization URL
        """
        if not self.google_client_id:
            raise ExternalServiceError("Google OAuth not configured")
        
        base_url = "https://accounts.google.com/o/oauth2/v2/auth"
        params = {
            'client_id': self.google_client_id,
            'redirect_uri': redirect_uri,
            'scope': 'openid email profile',
            'response_type': 'code',
            'access_type': 'offline',
            'prompt': 'consent'
        }
        
        if state:
            params['state'] = state
        
        query_string = '&'.join([f"{key}={value}" for key, value in params.items()])
        return f"{base_url}?{query_string}"
    
    def exchange_google_code(self, code: str, redirect_uri: str) -> Dict[str, Any]:
        """
        Exchange Google authorization code for tokens
        
        Args:
            code: Authorization code from Google
            redirect_uri: Redirect URI used in authorization
            
        Returns:
            Dictionary containing tokens and user info
            
        Raises:
            AuthenticationError: If code exchange fails
            ExternalServiceError: If Google service is unavailable
        """
        if not self.google_client_id or not self.google_client_secret:
            raise ExternalServiceError("Google OAuth not configured")
        
        try:
            # Exchange code for tokens
            token_url = "https://oauth2.googleapis.com/token"
            token_data = {
                'client_id': self.google_client_id,
                'client_secret': self.google_client_secret,
                'code': code,
                'grant_type': 'authorization_code',
                'redirect_uri': redirect_uri
            }
            
            response = requests.post(token_url, data=token_data, timeout=10)
            
            if response.status_code == 200:
                token_info = response.json()
                access_token = token_info.get('access_token')
                id_token_str = token_info.get('id_token')
                
                # Get user info using the access token
                user_info = self._verify_google_token(access_token)
                
                return {
                    'access_token': access_token,
                    'id_token': id_token_str,
                    'user_info': user_info
                }
            else:
                logger.error(f"Google token exchange failed: {response.text}")
                raise AuthenticationError("Failed to exchange Google authorization code")
                
        except requests.RequestException as e:
            logger.error(f"Google token exchange request failed: {str(e)}")
            raise ExternalServiceError("Google authentication service unavailable")
    
    def is_google_configured(self) -> bool:
        """Check if Google OAuth is properly configured"""
        return bool(self.google_client_id and self.google_client_secret)
    
    def is_apple_configured(self) -> bool:
        """Check if Apple Sign In is properly configured"""
        return bool(self.apple_client_id and self.apple_client_secret) 