import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class FilterUserDto {
  @ApiPropertyOptional({
    description: 'Filter by email (contains match)',
    example: 'user@example.com',
  })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({
    description: 'Filter by name (contains match)',
    example: 'user',
  })
  @IsOptional()
  @IsString()
  name?: string;
}
