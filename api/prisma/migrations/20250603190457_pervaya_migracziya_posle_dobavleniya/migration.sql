-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "mandala_app";

-- CreateTable
CREATE TABLE "mandala_app"."User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mandala_app"."UserData" (
    "userId" TEXT NOT NULL,
    "profileUrl" TEXT,
    "metadata" JSONB,

    CONSTRAINT "UserData_pkey" PRIMARY KEY ("userId")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "mandala_app"."User"("email");

-- AddForeignKey
ALTER TABLE "mandala_app"."UserData" ADD CONSTRAINT "UserData_userId_fkey" FOREIGN KEY ("userId") REFERENCES "mandala_app"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
