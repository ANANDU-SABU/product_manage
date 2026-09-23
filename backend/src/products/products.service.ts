import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';

@Injectable()
export class ProductsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateProductDto) {
    return this.prisma.product.create({
      data: {
        name: dto.name,
        category: dto.category,
        quantity: dto.quantity,
        price: dto.price,
        userId,
      },
    });
  }

  async findAll(userId: string) {
    return this.prisma.product.findMany({
      where: {
        userId,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(userId: string, id: string) {
    const product = await this.prisma.product.findFirst({
      where: {
        id,
        userId,
      },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    return product;
  }

  async update(userId: string, id: string, dto: CreateProductDto) {
    const product = await this.prisma.product.findFirst({
      where: {
        id,
        userId,
      },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    return this.prisma.product.update({
      where: {
        id,
      },
      data: {
        name: dto.name,
        category: dto.category,
        quantity: dto.quantity,
        price: dto.price,
      },
    });
  }

  async remove(userId: string, id: string) {
    const product = await this.prisma.product.findFirst({
      where: {
        id,
        userId,
      },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    await this.prisma.product.delete({
      where: {
        id,
      },
    });

    return {
      message: 'Product deleted successfully',
    };
  }
}