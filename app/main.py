from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def root():
    return {"message": "Hello, FastAPI running in Docker Stack!"}


@app.get("/health")
def healthcheck():
    return {"status": "ok"}
