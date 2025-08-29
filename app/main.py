from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional
from utils import cut_youtube
import io


app = FastAPI()


class YouTubeCutRequest(BaseModel):
    url: str
    initial: Optional[str] = None
    final: Optional[str] = None


@app.get("/")
def root():
    return {"message": "Hello, FastAPI running in Docker Stack!"}


@app.get("/health")
def healthcheck():
    return {"status": "ok"}


@app.post("/youtube/cut")
def youtube_cut(request: YouTubeCutRequest):
    try:
        # Call util function
        video_bytes: bytes = cut_youtube(
            url=request.url,
            initial=request.initial,
            final=request.final
        )

        # Wrap binary in BytesIO for streaming
        return StreamingResponse(
            io.BytesIO(video_bytes),
            media_type="video/mp4",
            headers={"Content-Disposition": "attachment; filename=video_cut.mp4"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing video: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
