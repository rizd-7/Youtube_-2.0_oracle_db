# Node.js Application with Oracle Database Integration

This project is a Node.js application that integrates with an Oracle database. It allows users to fetch and display video data and recommendations based on user preferences.

## Features
- Fetch video data from an Oracle database.
- Render data using EJS templates.
- Provide video recommendations.
- Serve static files from the `public` directory.

## Technologies Used
- **Node.js**: Backend server framework.
- **Express.js**: For routing and middleware.
- **Oracle Database**: Backend database.
- **EJS**: Templating engine for rendering views.

## Installation and Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Configure Oracle Database**
   Update the `dbConfig` object in the code with your Oracle database credentials:
   ```javascript
   const dbConfig = {
     user: "c##zestream",
     password: "zestream",
     connectString: "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521)))(CONNECT_DATA=(SID=orcl)))",
   };
   ```

4. **Run the Application**
   ```bash
   node app.js
   ```

5. **Access the Application**
   Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

## Project Structure
```
.
├── app.js          # Main application file
├── public/         # Static files (CSS, JS, images, etc.)
├── views/          # EJS templates
├── package.json    # Node.js dependencies
└── README.md       # Project documentation
```

## Key Endpoints

### `/`
- Fetch and display all video data from the Oracle database.

### `/video/:id-:content`
- Fetch video details and recommendations for a specific video.
- Parameters:
  - `id`: Video ID.
  - `content`: Video content description.

## Notes

### Database Tables Used
- **`c##zestreamadmin.videos`**: Stores video details.
- **`c##zestreamadmin.RecommendationResults`**: Stores recommendation results for users.

### Helper Functions
- **`queryDatabase(query)`**: Executes a query on the Oracle database and processes the results.
- **`blobToBase64(blob)`**: Converts BLOB data to Base64 format for thumbnails.

## Future Improvements
- Add user authentication.
- Enhance error handling and logging.
- Optimize database queries for performance.



