FROM node:18-alpine
WORKDIR /docker
COPY patient-service.js ./
#RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "patient-service.js"]