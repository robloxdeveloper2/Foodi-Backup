"""
Email Service
Handles email sending functionality
"""

import os
import smtplib
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Optional

logger = logging.getLogger(__name__)

class EmailService:
    """Service for sending emails"""
    
    def __init__(self):
        self.smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
        self.smtp_port = int(os.getenv('SMTP_PORT', 587))
        self.smtp_username = os.getenv('SMTP_USERNAME')
        self.smtp_password = os.getenv('SMTP_PASSWORD')
        self.from_email = os.getenv('FROM_EMAIL')
        self.app_name = os.getenv('APP_NAME', 'Foodi')
        self.frontend_url = os.getenv('FRONTEND_URL', 'http://localhost:3000')
    
    def send_verification_email(self, to_email: str, verification_token: str) -> bool:
        """
        Send email verification email
        
        Args:
            to_email: Recipient email address
            verification_token: Email verification token
            
        Returns:
            True if email sent successfully, False otherwise
        """
        try:
            if not self._is_email_configured():
                logger.warning("Email service not configured, skipping email sending")
                return False
            
            subject = f"Verify your {self.app_name} account"
            verification_url = f"{self.frontend_url}/verify-email?token={verification_token}"
            
            # Create HTML email content
            html_content = self._create_verification_email_html(verification_url)
            text_content = self._create_verification_email_text(verification_url)
            
            return self._send_email(to_email, subject, text_content, html_content)
            
        except Exception as e:
            logger.error(f"Failed to send verification email to {to_email}: {str(e)}")
            return False
    
    def send_password_reset_email(self, to_email: str, reset_token: str) -> bool:
        """
        Send password reset email
        
        Args:
            to_email: Recipient email address
            reset_token: Password reset token
            
        Returns:
            True if email sent successfully, False otherwise
        """
        try:
            if not self._is_email_configured():
                logger.warning("Email service not configured, skipping email sending")
                return False
            
            subject = f"Reset your {self.app_name} password"
            reset_url = f"{self.frontend_url}/reset-password?token={reset_token}"
            
            # Create HTML email content
            html_content = self._create_password_reset_email_html(reset_url)
            text_content = self._create_password_reset_email_text(reset_url)
            
            return self._send_email(to_email, subject, text_content, html_content)
            
        except Exception as e:
            logger.error(f"Failed to send password reset email to {to_email}: {str(e)}")
            return False
    
    def send_welcome_email(self, to_email: str, first_name: Optional[str] = None) -> bool:
        """
        Send welcome email to new users
        
        Args:
            to_email: Recipient email address
            first_name: User's first name
            
        Returns:
            True if email sent successfully, False otherwise
        """
        try:
            if not self._is_email_configured():
                logger.warning("Email service not configured, skipping email sending")
                return False
            
            subject = f"Welcome to {self.app_name}!"
            
            # Create HTML email content
            html_content = self._create_welcome_email_html(first_name)
            text_content = self._create_welcome_email_text(first_name)
            
            return self._send_email(to_email, subject, text_content, html_content)
            
        except Exception as e:
            logger.error(f"Failed to send welcome email to {to_email}: {str(e)}")
            return False
    
    def _send_email(self, to_email: str, subject: str, text_content: str, 
                   html_content: Optional[str] = None) -> bool:
        """
        Send email using SMTP
        
        Args:
            to_email: Recipient email address
            subject: Email subject
            text_content: Plain text email content
            html_content: HTML email content (optional)
            
        Returns:
            True if email sent successfully, False otherwise
        """
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From'] = self.from_email
            msg['To'] = to_email
            
            # Add text part
            text_part = MIMEText(text_content, 'plain')
            msg.attach(text_part)
            
            # Add HTML part if provided
            if html_content:
                html_part = MIMEText(html_content, 'html')
                msg.attach(html_part)
            
            # Send email
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_username, self.smtp_password)
                server.send_message(msg)
            
            logger.info(f"Email sent successfully to {to_email}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to send email to {to_email}: {str(e)}")
            return False
    
    def _is_email_configured(self) -> bool:
        """Check if email service is properly configured"""
        return all([
            self.smtp_username,
            self.smtp_password,
            self.from_email
        ])
    
    def _create_verification_email_html(self, verification_url: str) -> str:
        """Create HTML content for verification email"""
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Verify Your Email</title>
        </head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h1 style="color: #4CAF50;">{self.app_name}</h1>
                <h2>Verify Your Email Address</h2>
                <p>Thank you for signing up for {self.app_name}! To complete your registration, please verify your email address by clicking the button below:</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{verification_url}" 
                       style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                        Verify Email Address
                    </a>
                </div>
                
                <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
                <p style="word-break: break-all; color: #666;">{verification_url}</p>
                
                <p>This verification link will expire in 24 hours for security reasons.</p>
                
                <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
                <p style="font-size: 12px; color: #666;">
                    If you didn't create an account with {self.app_name}, you can safely ignore this email.
                </p>
            </div>
        </body>
        </html>
        """
    
    def _create_verification_email_text(self, verification_url: str) -> str:
        """Create plain text content for verification email"""
        return f"""
{self.app_name} - Verify Your Email Address

Thank you for signing up for {self.app_name}! To complete your registration, please verify your email address by visiting the following link:

{verification_url}

This verification link will expire in 24 hours for security reasons.

If you didn't create an account with {self.app_name}, you can safely ignore this email.
        """
    
    def _create_password_reset_email_html(self, reset_url: str) -> str:
        """Create HTML content for password reset email"""
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Reset Your Password</title>
        </head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h1 style="color: #4CAF50;">{self.app_name}</h1>
                <h2>Reset Your Password</h2>
                <p>We received a request to reset your password. Click the button below to create a new password:</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{reset_url}" 
                       style="background-color: #FF6B6B; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                        Reset Password
                    </a>
                </div>
                
                <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
                <p style="word-break: break-all; color: #666;">{reset_url}</p>
                
                <p>This password reset link will expire in 1 hour for security reasons.</p>
                
                <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
                <p style="font-size: 12px; color: #666;">
                    If you didn't request a password reset, you can safely ignore this email.
                </p>
            </div>
        </body>
        </html>
        """
    
    def _create_password_reset_email_text(self, reset_url: str) -> str:
        """Create plain text content for password reset email"""
        return f"""
{self.app_name} - Reset Your Password

We received a request to reset your password. Visit the following link to create a new password:

{reset_url}

This password reset link will expire in 1 hour for security reasons.

If you didn't request a password reset, you can safely ignore this email.
        """
    
    def _create_welcome_email_html(self, first_name: Optional[str] = None) -> str:
        """Create HTML content for welcome email"""
        greeting = f"Hi {first_name}!" if first_name else "Welcome!"
        
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Welcome to {self.app_name}</title>
        </head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h1 style="color: #4CAF50;">{self.app_name}</h1>
                <h2>{greeting}</h2>
                <p>Welcome to {self.app_name}! We're excited to help you on your culinary journey.</p>
                
                <p>With {self.app_name}, you can:</p>
                <ul>
                    <li>Discover personalized meal plans</li>
                    <li>Find recipes that match your dietary preferences</li>
                    <li>Track your nutritional goals</li>
                    <li>Get cooking guidance and tips</li>
                </ul>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{self.frontend_url}" 
                       style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                        Start Exploring
                    </a>
                </div>
                
                <p>If you have any questions, feel free to reach out to our support team.</p>
                
                <p>Happy cooking!</p>
                <p>The {self.app_name} Team</p>
            </div>
        </body>
        </html>
        """
    
    def _create_welcome_email_text(self, first_name: Optional[str] = None) -> str:
        """Create plain text content for welcome email"""
        greeting = f"Hi {first_name}!" if first_name else "Welcome!"
        
        return f"""
{self.app_name} - {greeting}

Welcome to {self.app_name}! We're excited to help you on your culinary journey.

With {self.app_name}, you can:
- Discover personalized meal plans
- Find recipes that match your dietary preferences
- Track your nutritional goals
- Get cooking guidance and tips

Visit {self.frontend_url} to start exploring.

If you have any questions, feel free to reach out to our support team.

Happy cooking!
The {self.app_name} Team
        """ 