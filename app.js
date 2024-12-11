const express = require("express");
const oracledb = require("oracledb"); // Import the Oracle DB package
const app = express();

app.set("view engine", "ejs");
app.use("/", express.static("./public"));
app.use("/video", express.static("./public"));

// Oracle DB connection configuration
const dbConfig = {
  user: "c##zestream", // Your Oracle database username
  password: "zestream", // Your Oracle database password
  connectString:
    "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521)))(CONNECT_DATA=(SID=orcl)))",
};

// Function to connect to the Oracle database and run a query

async function queryDatabase(query) {
  let connection;
  try {
    // Establish a connection to the Oracle database
    connection = await oracledb.getConnection(dbConfig);

    // Fetch the video data

    const result = await connection.execute(query);

    // Process each row
    const processedData = await Promise.all(
      result.rows.map(async (row) => {
        const [
          id,
          title,
          category,
          description,
          content,
          length,
          postedBy,
          publishDate,
          rating,
          thumbnail,
        ] = row;

        // Convert CLOB to string
        const descriptionText = description
          ? await description.getData()
          : null;

        // Convert BLOB to Base64
        const thumbnailBase64 = thumbnail
          ? await blobToBase64(thumbnail)
          : null;

        return {
          id,
          title,
          category,
          description: descriptionText,
          content,
          length,
          postedBy,
          publishDate: publishDate.toISOString(),
          rating,
          thumbnail: thumbnailBase64,
        };
      })
    );

    return processedData; // Return processed data
  } catch (err) {
    console.error("Error connecting to the database:", err);
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error("Error closing connection:", err);
      }
    }
  }
}

async function queryDatabase2(query) {
  let connection;
  try {
    // Establish a connection to the Oracle database
    connection = await oracledb.getConnection(dbConfig);
    const result = await connection.execute(query);

    // Process each row
    const processedData = await Promise.all(
      result.rows.map(async (row) => {
        const [USER_ID, predicted_video_id, probability] = row;

        return {
          USER_ID,
          predicted_video_id,
          probability,
        };
      })
    );

    return processedData; // Return processed data
  } catch (err) {
    console.error("Error connecting to the database:", err);
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error("Error closing connection:", err);
      }
    }
  }
}

// Helper function to convert BLOB to Base64
function blobToBase64(blob) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    blob.on("data", (chunk) => chunks.push(chunk));
    blob.on("end", () => resolve(Buffer.concat(chunks).toString("base64")));
    blob.on("error", (err) => reject(err));
  });
}

// Call the function and send the data to
app.get("/video/:id-:content", async (req, res) => {
  const videoId = parseInt(req.params.id);
  const content = decodeURIComponent(req.params.content);

  const resultPred = await queryDatabase2(
    `SELECT * FROM c##zestreamadmin.RecommendationResults where user_id=4`
  );

  const resultvideoIDs = resultPred.map((row) => row.predicted_video_id);

  // Fetch recommended videos if anys
  let recommendedVideos = [];
  if (resultvideoIDs.length > 0) {
    const idList = resultvideoIDs.join(", ");
    recommendedVideos = await queryDatabase(
      `SELECT * FROM c##zestreamadmin.videos WHERE id IN (${idList})`
    );
  }

  const videos = await queryDatabase(
    `SELECT * FROM c##zestreamadmin.videos where id=${videoId}`
  );

  res.status(200).render("videoplay.ejs", {
    videos: videos[0],
    recomendation: recommendedVideos,
  });
});

// Route to handle requests and render the data
app.get("/", async (req, res) => {
  try {
    const videos = await queryDatabase("SELECT * FROM c##zestreamadmin.videos"); // Get data from the DB
    res.render("index", { videos });
  } catch (err) {
    res.status(500).send("Database query failed.");
  }
});

const port = 3000;
const start = () => {
  app.listen(port, () => console.log(`Server is listening on port ${port}...`));
};

start();
