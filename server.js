const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { exec } = require("child_process");

const app = express();

const SWIFT_EXE = path.join(__dirname, "swift-code", "MalwareApp.swift");
const UPLOADS_DIR = path.join(__dirname, "uploads");

app.use(express.json());

// GET /cheekyboy
app.get("/cheekyboy", (req, res) => {
    const image = path.basename(req.query.image || "");
    if (!image) return res.status(400).json({ error: "image query param required" });

    const imagePath = path.join(UPLOADS_DIR, image);

    if (!fs.existsSync(imagePath)) {
        return res.status(404).json({ error: "Image not found" });
    }

    exec(`swift run ${SWIFT_EXE} ${imagePath}`, (err, stdout, stderr) => {
        if (err) return res.status(500).json({ error: stderr || err.message });

        res.json({ image, output: stdout.trim() });
    });
});

// Create uploads directory if it doesn't exist
fs.mkdirSync(UPLOADS_DIR, { recursive: true });

// Configure image storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, UPLOADS_DIR);
    },
    filename: (req, file, cb) => {
        const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${path.extname(file.originalname)}`;
        cb(null, filename);
    }
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024
    },
    fileFilter: (req, file, cb) => {
        if (!file.mimetype.startsWith("image/")) {
            return cb(new Error("Only image files are allowed"));
        }

        cb(null, true);
    }
});

// Receive uploaded images
app.post("/uploads", upload.single("image"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: "No image received" });
    }

    res.status(200).json({ message: "Image successfully received", filename: req.file.filename });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`);
});