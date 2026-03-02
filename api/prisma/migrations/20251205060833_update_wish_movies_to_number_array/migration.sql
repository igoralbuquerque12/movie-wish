/*
  Warnings:

  - You are about to drop the `wish_movies` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "wish_movies" DROP CONSTRAINT "wish_movies_user_id_fkey";

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "wish_movies" INTEGER[];

-- DropTable
DROP TABLE "wish_movies";
