from pydantic import BaseModel


class LeaderboardEntry(BaseModel):
    rank: int
    user_id: str
    name: str
    xp: int
    is_current_user: bool = False

    class Config:
        from_attributes = True
