"""Tests for agent schemas."""

import pytest
from pydantic import ValidationError

from agent.schema import ChatMessage, StreamRequest, FeedbackRequest


class TestChatMessage:
    """Tests for ChatMessage schema."""

    def test_valid_message(self):
        msg = ChatMessage(role="human", content="Hello")
        assert msg.role == "human"
        assert msg.content == "Hello"
        assert msg.tool_calls is None

    def test_message_with_tool_calls(self):
        msg = ChatMessage(
            role="ai",
            content="Let me check that.",
            tool_calls=[{"name": "search", "args": {"q": "test"}}],
        )
        assert msg.tool_calls is not None
        assert len(msg.tool_calls) == 1

    def test_missing_required_fields(self):
        with pytest.raises(ValidationError):
            ChatMessage()


class TestStreamRequest:
    """Tests for StreamRequest schema."""

    def test_valid_request(self):
        req = StreamRequest(message="Hello")
        assert req.message == "Hello"
        assert req.thread_id is None

    def test_with_thread_id(self):
        req = StreamRequest(message="Hello", thread_id="abc-123")
        assert req.thread_id == "abc-123"

    def test_empty_message_rejected(self):
        with pytest.raises(ValidationError):
            StreamRequest()


class TestFeedbackRequest:
    """Tests for FeedbackRequest schema."""

    def test_valid_feedback(self):
        req = FeedbackRequest(run_id="run-123", score=0.8)
        assert req.run_id == "run-123"
        assert req.score == 0.8
        assert req.comment is None

    def test_score_boundaries(self):
        FeedbackRequest(run_id="run-123", score=0.0)
        FeedbackRequest(run_id="run-123", score=1.0)

    def test_score_out_of_range(self):
        with pytest.raises(ValidationError):
            FeedbackRequest(run_id="run-123", score=1.5)
        with pytest.raises(ValidationError):
            FeedbackRequest(run_id="run-123", score=-0.1)
