import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timedelta
from app.core.config import settings

class VideoService:
    def __init__(self):
        self.s3 = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY,
            aws_secret_access_key=settings.AWS_SECRET_KEY,
            region_name=settings.AWS_REGION
        )
        self.bucket = settings.S3_BUCKET_NAME
    
    def upload_video(self, file_bytes, filename: str, course_id: int) -> str:
        key = f"courses/{course_id}/videos/{filename}"
        self.s3.upload_fileobj(
            file_bytes,
            self.bucket,
            key,
            ExtraArgs={'ContentType': 'video/mp4'}
        )
        return key
    
    def generate_signed_url(self, s3_key: str, expires_in: int = 3600) -> str:
        """URL موقت برای پخش (جلوگیری از دانلود مستقیم)"""
        try:
            url = self.s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': self.bucket, 'Key': s3_key},
                ExpiresIn=expires_in
            )
            return url
        except ClientError:
            return None
    
    def delete_video(self, s3_key: str) -> bool:
        try:
            self.s3.delete_object(Bucket=self.bucket, Key=s3_key)
            return True
        except ClientError:
            return False
    